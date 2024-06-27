#!/bin/bash
echo "*****************************************"
echo "                                         "
echo "         Welcome to js-downloader        "
echo "           Created by Shahariar          "
echo "                                         "
echo "*****************************************"

# Prompt the user for the base URL
read -p "Enter the base URL (e.g., https://www.dailyom.com): " base_url

# File containing the list of subdomains or target URLs
subdomains_file="httpx_subd.txt"

# Create a directory for JavaScript files
mkdir -p js_files

# Array to keep track of downloaded file names
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
    if [[ ! "${downloaded_files[$file_name]}" ]]; then
      wget -P js_files "$download_url"
      downloaded_files["$file_name"]=1
    fi
  done

  rm page.html js_files_tmp.txt
}

# Process each URL in the subdomains file
while IFS= read -r url; do
  echo "Processing $url"
  download_js_files "$url"
done < "$subdomains_file"

echo "JavaScript files have been downloaded to the js_files directory."
cd js_files;
rm -rf *.js.* ;
