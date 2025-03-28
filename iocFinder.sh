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
    echo "1. MD5 Hash"
    echo "2. SHA-1 Hash"
    echo "3. SHA-256 Hash"
    echo "4. File Size (in bytes)"
    echo "5. File Name"
    echo "6. Strings Search"
    echo "7. File Extension Search"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6, or 7): " choice

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
        read -p "Enter the file size in bytes to search for: " size
        find "$path" -type f -size ${size}c -print || echo "No match found."
        ;;
      5)
        read -p "Enter the file name (or part of it) to search for: " filename
        find "$path" -type f -iname "*$filename*" -print || echo "No match found."
        ;;
      6)
        read -p "Enter the string to search for within files: " search_string
        echo "Searching for '$search_string' in files under $path..."
  
        # Search using grep with recursive option and print matching files
        grep -ril --binary-files=text "$search_string" "$path" 2>/dev/null
        if [ $? -eq 0 ]; then
        echo "Search completed."
        else
        echo "No match found."
        fi
        ;;
      7)
        read -p "Enter the file extension to search for (e.g., .exe, .dll, .log, .txt): " extension
        find "$path" -type f -name "*$extension" -print || echo "No match found."
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
