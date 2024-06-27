#!/bin/bash

echo "*****************************************"
echo "                                         "
echo "         Welcome to js-downloader        "
echo "           Created by Shahariar          "
echo "                                         "
echo "*****************************************"

# Prompt the user for the base URL
read -p "Enter the base URL (e.g., https://www.example.com): " base_url

# Prompt the user for the subdomains file
read -p "Enter the subdomains file (e.g., subdomains.txt): " subdomains_file

# Check if the subdomains file exists
if [[ ! -f "$subdomains_file" ]]; then
  echo "The subdomains file '$subdomains_file' does not exist."
  exit 1
fi

# Create a directory for JavaScript files
mkdir -p js_files

# Array to keep track of downloaded file names and URLs
declare -A downloaded_files

# Function to download JavaScript files
download_js_files() {
  local url="$1"
  
  # Download the HTML content of the target URL
  wget -q -O page.html "$url"

  # Extract JavaScript file URLs from the downloaded HTML content
  grep -oP '(?<=src=")[^"]+\.js' page.html > js_files_tmp.txt

  # Download JavaScript files
  cat js_files_tmp.txt | while read -r js_url; do
    if [[ "$js_url" =~ ^http ]]; then
      download_url="$js_url"
    else
      download_url="$base_url/$js_url"
    fi
    
    # Extract the filename from the URL
    file_name=$(basename "$download_url")

    # Check if file has already been downloaded (based on filename)
    if [[ ! -e "js_files/$file_name" && ! "${downloaded_files[$file_name]}" ]]; then
      wget -P js_files "$download_url"
      downloaded_files["$file_name"]=1
      echo "$download_url" >> urls.txt  # Store download URL in urls.txt
    fi
  done

  rm page.html js_files_tmp.txt
}

# Process each URL in the subdomains file
while IFS= read -r url; do
  echo "Processing $url"
  download_js_files "$url"
done < "$subdomains_file"

# Remove duplicate URLs in urls.txt
sort -u -o urls.txt urls.txt

# Clean up unnecessary files
cd js_files || exit 1  # Change directory to js_files
rm -rf *.js.*           # Remove redundant files

echo "JavaScript files have been downloaded to the js_files directory."
echo "Download URLs have been stored in urls.txt without duplicates."
