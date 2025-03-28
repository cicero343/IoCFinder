# PowerShell Script to Search for Files by MD5, SHA-1, SHA-256, File Size, File Name, Strings, or File Extension

$asciiArt = @"
  ___       ____   _____ _           _           
 |_ _|___  / ___| |  ___(_)_ __   __| | ___ _ __ 
  | |/ _ \| |     | |_  | | '_ \ / _` |/ _ \ '__|
  | | (_) | |___  |  _| | | | | | (_| |  __/ |   
 |___\___/ \____| |_|   |_|_| |_|\__,_|\___|_|   
 
"@
Write-Host $asciiArt
Write-Host "Hi, I'm IoC Finder, your pocket-sized search tool! What directory should I scan for Indicators of Compromise?"

function Choose-Directory {
    return Read-Host "Enter the directory to search (e.g., C:\Path\To\Search)"
}

function Perform-Search {
    param (
        [string]$path
    )

    $start = $true

    while ($start) {
        Write-Host "What would you like to search for?"
        Write-Host "1. MD5 Hash"
        Write-Host "2. SHA-1 Hash"
        Write-Host "3. SHA-256 Hash"
        Write-Host "4. File Size (in bytes)"
        Write-Host "5. File Name"
        Write-Host "6. Strings Search"
        Write-Host "7. File Extension Search"
        $choice = Read-Host "Enter your choice (1, 2, 3, 4, 5, 6, or 7)"

        if ($choice -eq "1") {
            $hash = Read-Host "Enter the MD5 hash to search for"
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                $fileHash = Get-FileHash $_.FullName -Algorithm MD5
                if ($fileHash.Hash -eq $hash) {
                    Write-Host "Match Found: $($_.FullName)"
                }
            }
        }
        elseif ($choice -eq "2") {
            $hash = Read-Host "Enter the SHA-1 hash to search for"
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                $fileHash = Get-FileHash $_.FullName -Algorithm SHA1
                if ($fileHash.Hash -eq $hash) {
                    Write-Host "Match Found: $($_.FullName)"
                }
            }
        }
        elseif ($choice -eq "3") {
            $hash = Read-Host "Enter the SHA-256 hash to search for"
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                $fileHash = Get-FileHash $_.FullName -Algorithm SHA256
                if ($fileHash.Hash -eq $hash) {
                    Write-Host "Match Found: $($_.FullName)"
                }
            }
        }
        elseif ($choice -eq "4") {
            $size = Read-Host "Enter the file size in bytes to search for"
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                if ($_.Length -eq $size) {
                    Write-Host "Match Found: $($_.FullName)"
                }
            }
        }
        elseif ($choice -eq "5") {
            $fileName = Read-Host "Enter the file name (or part of it) to search for"
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                if ($_.Name -like "*$fileName*") {
                    Write-Host "Match Found: $($_.FullName)"
                }
            }
        }
        elseif ($choice -eq "6") {
            $searchString = Read-Host "Enter the string to search for within files"
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                try {
                    $content = (Get-Content $_.FullName -Raw) -split '\s+'
                    $matches = $content | Where-Object { $_ -match '[\x20-\x7E]+' -and $_ -like "*$searchString*" }
                    if ($matches) {
                        Write-Host "Match Found in: $($_.FullName)"
                    }
                } catch {
                    Write-Host "Error reading file: $($_.FullName) - $_"
                }
            }
        }
        elseif ($choice -eq "7") {
            $extension = Read-Host "Enter the file extension to search for (e.g., .exe, .dll, .log, .txt)"
            Get-ChildItem -Path $path -Recurse -File -Filter "*$extension" | ForEach-Object {
                Write-Host "Match Found: $($_.FullName)"
            }
        }
        else {
            Write-Host "Invalid choice. Please enter a valid option."
        }

        Write-Host ""
        Write-Host "What would you like to do?"
        Write-Host "1. Back to 'Choose IoC' option"
        Write-Host "2. Back to 'Choose Directory' option"
        Write-Host "3. Quit"
        $action = Read-Host "Enter your choice (1, 2, or 3)"

        if ($action -eq "1") {
            continue
        }
        elseif ($action -eq "2") {
            $path = Choose-Directory
        }
        elseif ($action -eq "3") {
            Write-Host "See ya next time!"
            exit
        }
        else {
            Write-Host "Invalid choice. Returning to 'Choose IoC' option."
        }
    }
}

$path = Choose-Directory
Perform-Search -path $path