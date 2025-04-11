#!/bin/bash

cat << "EOF"
  ___       ____   _____ _           _           
 |_ _|___  / ___| |  ___(_)_ __   __| | ___ _ __ 
  | |/ _ \| |     | |_  | | '_ \ / _` |/ _ \ '__|
  | | (_) | |___  |  _| | | | | | (_| |  __/ |   
 |___\___/ \____| |_|   |_|_| |_|\__,_|\___|_|   
EOF

echo "Hi, I'm IoC Finder, your pocket-sized search tool! What directory should I scan for Indicators of Compromise?"

choose_directory() {
  read -p "Enter the directory to search (e.g., /path/to/search): " path
}

perform_search() {
  while true; do
    echo ""
    echo "What would you like to search for?"
    echo "Hashes:"
    echo "1. MD5 Hash"
    echo "2. SHA-1 Hash"
    echo "3. SHA-256 Hash"
    
    echo ""
    echo "File Data:"
    echo "4. File Name"
    echo "5. File Extension Search"
    echo "6. File Size (in bytes)"
    echo "7. Strings Search"
    echo "8. Files Recently Created/Accessed/Modified"
    
    echo ""
    echo "Executable Files:"
    echo "9. Metadata Search (Executable Files only)"
    echo "10. Authenticode Signature Check (Unsigned Executables - WINDOWS ONLY)"
    echo ""

    read -p "Enter your choice (1 - 10): " choice

    case $choice in
      1)
        read -p "Enter the MD5 hash to search for: " hash
        find "$path" -type f -exec md5sum {} + 2>/dev/null | grep -iw "$hash" && echo "Match Found!" || echo "No match found."
        ;;
      2)
        read -p "Enter the SHA-1 hash to search for: " hash
        find "$path" -type f -exec sha1sum {} + 2>/dev/null | grep -iw "$hash" && echo "Match Found!" || echo "No match found."
        ;;
      3)
        read -p "Enter the SHA-256 hash to search for: " hash
        find "$path" -type f -exec sha256sum {} + 2>/dev/null | grep -iw "$hash" && echo "Match Found!" || echo "No match found."
        ;;
      4)
        read -p "Enter the file name (or part of it) to search for: " filename
        find "$path" -type f -iname "*$filename*" -print || echo "No match found."
        ;;
      5)
        read -p "Enter the file extension to search for (e.g., .exe, .dll, .log, .txt): " extension
        find "$path" -type f -name "*$extension" -print || echo "No match found."
        ;;
      6)
        read -p "Enter the file size in bytes to search for: " size
        find "$path" -type f -size ${size}c -print || echo "No match found."
        ;;
      7)
        read -p "Enter the string to search for within files: " search_string
        echo "Searching for '$search_string' in files under $path..."
  
        grep -ril --binary-files=text "$search_string" "$path" 2>/dev/null
        if [ $? -eq 0 ]; then
          echo "Search completed."
        else
          echo "No match found."
        fi
        ;;
      8)
        read -p "Enter the date (DD/MM/YYYY) to search for recently created, accessed, or modified files: " date_input
        if [[ ! "$date_input" =~ ^[0-3][0-9]/[0-1][0-9]/[0-9]{4}$ ]]; then
          echo "Invalid date format. Please enter the date in DD/MM/YYYY format."
        else
          # Manually parse the date into the format YYYY-MM-DD for find
          day=$(echo $date_input | cut -d/ -f1)
          month=$(echo $date_input | cut -d/ -f2)
          year=$(echo $date_input | cut -d/ -f3)
          formatted_date="$year-$month-$day"
          
          echo "Searching for files created, accessed, or modified on $formatted_date..."

          # Search for files created on the date
          echo ""
          echo "Files created on $formatted_date:"
          find "$path" -type f -newermt "$formatted_date" ! -newermt "$formatted_date + 1 day" -print || echo "No files created on this date."

          # Search for files accessed on the date
          echo ""
          echo "Files accessed on $formatted_date:"
          find "$path" -type f -anewer "$formatted_date" ! -anewer "$formatted_date + 1 day" -print || echo "No files accessed on this date."

          # Search for files modified on the date
          echo ""
          echo "Files modified on $formatted_date:"
          find "$path" -type f -newermt "$formatted_date" ! -newermt "$formatted_date + 1 day" -print || echo "No files modified on this date."
        fi
        ;;
      9)
        read -p "Enter the keyword to search for in executable metadata (e.g., company name, product, version): " search_term
        echo "Scanning for executable metadata..."
        found=false
        find "$path" -type f \( -iname "*.exe" -or -iname "*.dll" \) -exec sh -c '
          file="$1"
          info=$(exiftool "$file" | grep -i "$2")
          if [[ -n "$info" ]]; then
            echo "$file"
            echo "$info"
            found=true
          fi
        ' _ {} "$search_term" \; || echo "No match found."
        ;;
      10)
        echo "Scanning for Authenticode signature status..."
        found=false
        find "$path" -type f \( -iname "*.exe" -or -iname "*.dll" \) -exec sh -c '
          file="$1"
          signature=$(sigcheck -q "$file")
          if [[ "$signature" != *"Signed"* ]]; then
            echo "Unsigned file: $file"
            found=true
          fi
        ' _ {} \; || echo "No unsigned files found."
        ;;
      *)
        echo "Invalid choice. Please enter a valid option."
        continue
        ;;
    esac

    echo ""
    echo "What would you like to do?"
    echo "1. Back to 'Choose IoC' option"
    echo "2. Back to 'Choose Directory' option"
    echo "3. Quit"
    read -p "Enter your choice (1, 2, or 3): " action

    case $action in
      1)
        continue
        ;;
      2)
        choose_directory
        ;;
      3)
        echo "See ya next time!"
        exit
        ;;
      *)
        echo "Invalid choice. Returning to 'Choose IoC' option."
        ;;
    esac
  done
}

choose_directory
perform_search
