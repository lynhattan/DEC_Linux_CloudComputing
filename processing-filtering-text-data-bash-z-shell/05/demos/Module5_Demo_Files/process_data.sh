#!/bin/sh

# Get the continent name from the argument passed to the script
# If the continent name is not provided, throw an error
continent="$@"
if [[ $continent == "" ]]; then
    echo "Continent name not provided!"
    exit
fi

# Check the existence of the source files in current directory
# If the files don't exist, throw an error
country_capitals_filename="country_capitals.txt"
capitals_lat_long_filename="capitals_lat_long.txt"

if [[ ! -f ./"$country_capitals_filename" ]]; then
    echo "Source file for countries and their capitals not present!"
    exit
fi

if [[ ! -f ./"$capitals_lat_long_filename" ]]; then
    echo "Source file for capitals and their location not present!"
    exit
fi

#Set some intermediary file names
country_capitals_filename_csv="country_capitals.csv"
capitals_lat_long_filename_csv="capitals_lat_long.csv"
joined_filename="country_capitals_lat_long.csv"

# Process the source files into CSV format
# # Get rid of empty lines, capitalize all entries
# # Use comma separator
cat \
  "$country_capitals_filename" | \
  tr [:lower:] [:upper:] | \
  tr \\t \, | \
  tr -s \\n | \
  sort -t \, -k3,3 > \
  "$country_capitals_filename_csv"

cat \
  "$capitals_lat_long_filename" | \
  tr [:lower:] [:upper:] | \
  sort -t \, -k1,1 > \
  "$capitals_lat_long_filename_csv"


# Join the two intermediary CSV files and create a third intermediary file
# Note how we are using the -o option to specify the order of columns in the output
join \
  -a 1 \
  -1 3 -2 1 \
  -t \,  \
  -o 1.1,1.2,2.1,2.2,2.3 \
  "$country_capitals_filename_csv" "$capitals_lat_long_filename_csv" > \
  "$joined_filename"

# Build the output file name
lowercase_continent=`echo "$continent" | tr '[:upper:]' '[:lower:]' | sed -e 's/^"//' -e 's/"$//'`
city_info_file_name_prefix=`echo "$lowercase_continent" | sed -e 's/ /_/'`
city_info_file="$city_info_file_name_prefix"_cities.csv

# Check the existence of the output file from previous runs
# If the file exists, drop it
if [[ -f ./"$city_info_file" ]]; then
    rm -f ./$city_info_file
fi
# Create the blank  output file
# Notice how we are using the touch command
touch ./$city_info_file

# Now start processing the joined file.
# Read each line and assign to a variable. 
# If the line starts with the supplied continent name, then append that line to the $city_info_file
# Also note how we are using the while loop to read the file line by line
while IFS= read -r line
do
  # Get the continent name from the first column of the lin
  continent_name=`echo "$line" | cut -f 1 -d \, | tr '[:upper:]' '[:lower:]'`
  if [[ "$continent_name" == "$lowercase_continent" ]]; then
    # If the line is for the continent name passed as an argument, then retain that line
    # and append to the destination file
    echo "$line" >> ./$city_info_file
  fi
done < "$joined_filename"

# Add a header row to the file
# We are using -i option to overwrite the output file
# We are also using the 1 i option with sed to insert the header row
header_row="CONTINENT,COUNTRY,CAPITAL,LATITUDE,LONGITUDE"
sed -i '1 i '"$header_row"'''' ./"$city_info_file"

# Remove the intermediary files
rm -f ./$country_capitals_filename_csv
rm -f ./$capitals_lat_long_filename_csv
rm -f ./$joined_filename

# Final message
echo "File processing complete!"
