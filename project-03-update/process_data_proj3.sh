#!/bin/bash

# Ingnore commas double quotes
sed -i 's/, / | /g' tmdb-movies.csv

# 1. Sắp xếp các bộ phim theo ngày phát hành giảm dần rồi lưu ra một file mới

sort -t ',' -k19,19 -k16nr -k16.3nr -k16.4nr -b -r -o tmdb-movies-sorted.csv  tmdb-movies.csv

# 2. Lọc ra các bộ phim có đánh giá trung bình trên 7.5 rồi lưu ra một file mới

awk -F ',' '{if ($18 >= 7.5) {print $0}}' tmdb-movies-sorted.csv >> tmdb-movies-voteavg-greater-than-7.5.csv

# 3. Tìm ra phim nào có doanh thu cao nhất và doanh thu thấp nhất

awk 'BEGIN{FS=OFS=","} {print $NF,$0}' tmdb-movies.csv | sort -t, -k1,1g | cut -d, -f2- | cut -d, -f6 | tail -1 > film_max_revenue

# 4. Tính tổng doanh thu tất cả các bộ phim

awk -F "," '{sum+=$NF} END {print "Total revenue of all films: " sum}' tmdb-movies.csv > total_revenue

# 5. Top 10 bộ phim đem về lợi nhuận cao nhất

awk 'BEGIN{ FS=OFS="," } { $(NF+1)=(NR==1? "profit_adj" : $(NF)-$(NF-1)); {print $0} }' tmdb-movies.csv > tmdb-movies-add-profit.csv
awk 'BEGIN{FS=OFS=","} {print $NF,$0}' tmdb-movies-add-profit.csv | sort -t, -k1,1g | cut -d, -f2- | cut -d, -f6 | tail -10 >> top_10_film_most_profit

# 6. Đạo diễn nào có nhiều bộ phim nhất và diễn viên nào đóng nhiều phim nhất

awk -F "," '{if ($9 != "") {print $9}}' tmdb-movies.csv | sort -nr | uniq -c | sort -n | tail -1 >> top1_director
cut -d "," -f 7 tmdb-movies.csv | awk -F "|" '{for(i=1;i<=NF;i++){printf "%s \n",$i}}' | sort | uniq -c | sort -nr >> top1_actor

# 7. Thống kê số lượng phim theo các thể loại. Ví dụ có bao nhiêu phim thuộc thể loại Action, bao nhiêu thuộc thể loại Family, ….

cut -d "," -f 14 tmdb-movies.csv | awk -F "|" '{for(i=1;i<=NF;i++){printf "%s \n",$i}}' | sort | uniq -ci | sort -nr >> number_films_by_genres

echo "Process data is completed"


