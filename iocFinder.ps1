# PowerShell Script to Search for Files by MD5, SHA-1, SHA-256, File Size, File Name, Strings, File Extension, Executable Metadata, or Authenticode Signature

$asciiArt = @"
  ___       ____   _____ _           _           
 |_ _|___  / ___| |  ___(_)_ __   __| | ___ _ __ 
  | |/ _ \| |     | |_  | | '_ \ / _` |/ _ \ '__|
  | | (_) | |___  |  _| | | | | | (_| |  __/ |   
 |___\___/ \____| |_|   |_|_| |_|\__,_|\___|_|   

"@
Write-Host $asciiArt
Write-Host "Hi, I'm IoC Finder, your pocket-sized search tool! What directory should I scan for Indicators of Compromise?"

# Function to choose directory either via GUI or manual input
function Choose-Directory {
    Write-Host "`nSelect directory input method:"
    Write-Host "[1] Browse via GUI"
    Write-Host "[2] Enter path manually"

    $method = Read-Host "Enter 1 or 2"

    if ($method -eq "1") {
        Add-Type -AssemblyName System.Windows.Forms
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select the directory to search"
        $folderBrowser.ShowNewFolderButton = $false

        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            return $folderBrowser.SelectedPath
        } else {
            Write-Host "No folder selected. Exiting." -ForegroundColor Red
            exit
        }
    } elseif ($method -eq "2") {
        return Read-Host "Enter the directory to search (e.g., C:\Path\To\Search)"
    } else {
        Write-Host "Invalid selection. Exiting." -ForegroundColor Red
        exit
    }
}

# Helper function for reading and validating date input (DD/MM/YYYY)
function Get-DateInput {
    param(
        [string]$prompt
    )
    $dateInput = Read-Host $prompt
    if ($dateInput -match '^\d{2}/\d{2}/\d{4}$') {
        return $dateInput
    }
    else {
        Write-Host "Invalid date format. Please enter the date in DD/MM/YYYY format."
        return $null
    }
}

# Helper function to convert a string to DateTime
function Convert-ToDateTime {
    param (
        [string]$dateStr
    )
    return [datetime]::ParseExact($dateStr, 'dd/MM/yyyy', $null)
}

function Perform-Search {
    param (
        [string]$path
    )
    $start = $true

    while ($start) {
        Write-Host "`nWhat would you like to search for?"
        Write-Host "`nHashes:"
        Write-Host "1. MD5 Hash"
        Write-Host "2. SHA-1 Hash"
        Write-Host "3. SHA-256 Hash"
        
        Write-Host "`nFile Data:"
        Write-Host "4. File Name"
        Write-Host "5. File Extension Search"
        Write-Host "6. File Size (in bytes)"
        Write-Host "7. Strings Search"
        Write-Host "8. Files Recently Created/Accessed/Modified"

        Write-Host "`nExecutable Files:"
        Write-Host "9. Metadata Search (Executable Files only)"
        Write-Host "10. Authenticode Signature Check (Unsigned Executables)"

        Write-Host ""

        $choice = Read-Host "Enter your choice (1 - 10)"

        if ($choice -eq "8") {
            Write-Host "`nFiles Recently Created/Accessed/Modified"
            $dateStr = Get-DateInput "Enter the date (DD/MM/YYYY):"
            if ($dateStr) {
                $date = Convert-ToDateTime $dateStr
                Write-Host "`nSearching for files on $dateStr..."

                # Search for files matching the created, accessed, or modified date
                $createdFiles = Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.CreationTime.Date -eq $date.Date }
                $accessedFiles = Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.LastAccessTime.Date -eq $date.Date }
                $modifiedFiles = Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.LastWriteTime.Date -eq $date.Date }

                # Display headers with color
                Write-Host "`n" -ForegroundColor Cyan
                Write-Host "Created Files: " -ForegroundColor Green
                if ($createdFiles) {
                    $createdFiles | ForEach-Object {
                        Write-Host "  $($_.FullName)" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "  No files found." -ForegroundColor Red
                }

                Write-Host "`nAccessed Files: " -ForegroundColor Green
                if ($accessedFiles) {
                    $accessedFiles | ForEach-Object {
                        Write-Host "  $($_.FullName)" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "  No files found." -ForegroundColor Red
                }

                Write-Host "`nModified Files: " -ForegroundColor Green
                if ($modifiedFiles) {
                    $modifiedFiles | ForEach-Object {
                        Write-Host "  $($_.FullName)" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "  No files found." -ForegroundColor Red
                }
            }
        }
        elseif ($choice -in "1", "2", "3") {
            $alg = if ($choice -eq "1") { "MD5" } elseif ($choice -eq "2") { "SHA1" } else { "SHA256" }
            $hash = Read-Host "Enter the $alg hash to search for"
            Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
                try {
                    $fileHash = Get-FileHash $_.FullName -Algorithm $alg
                    if ($fileHash.Hash -eq $hash) {
                        Write-Host "Match Found: $($_.FullName)"
                    }
                } catch {
                    Write-Host "Error processing: $($_.FullName) - $_"
                }
            }
        }
        elseif ($choice -eq "4") {
            $fileName = Read-Host "Enter the file name (or part of it) to search for"
            Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.Name -like "*$fileName*" } | ForEach-Object {
                Write-Host "Match Found: $($_.FullName)"
            }
        }
        elseif ($choice -eq "5") {
            $extension = Read-Host "Enter the file extension to search for (e.g., .exe, .dll, .log, .txt)"
            Get-ChildItem -Path $path -Recurse -File -Filter "*$extension" | ForEach-Object {
                Write-Host "Match Found: $($_.FullName)"
            }
        }
        elseif ($choice -eq "6") {
            $size = Read-Host "Enter the file size in bytes to search for"
            Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.Length -eq $size } | ForEach-Object {
                Write-Host "Match Found: $($_.FullName)"
            }
        }
        elseif ($choice -eq "7") {
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
        elseif ($choice -eq "9") {
            Write-Host "`nScanning for executable metadata..."
            $searchTerm = Read-Host "Enter the keyword to search for in executable metadata (e.g., company name, product, version)"
            $found = $false

            Get-ChildItem -Path $path -Recurse -File | Where-Object {
                $_.Extension -match "\.exe$|\.dll$"
            } | ForEach-Object {
                try {
                    $info = $_.VersionInfo
                    if ($info -and (
                        $info.CompanyName -like "*$searchTerm*" -or
                        $info.ProductName -like "*$searchTerm*" -or
                        $info.FileDescription -like "*$searchTerm*" -or
                        $info.OriginalFilename -like "*$searchTerm*" -or
                        $info.FileVersion -like "*$searchTerm*" -or
                        $info.ProductVersion -like "*$searchTerm*"
                    )) {
                        Write-Host "`nFile: $($_.FullName)"
                        Write-Host "  Company: $($info.CompanyName)"
                        Write-Host "  Product: $($info.ProductName)"
                        Write-Host "  Description: $($info.FileDescription)"
                        Write-Host "  Original Filename: $($info.OriginalFilename)"
                        Write-Host "  File Version: $($info.FileVersion)"
                        Write-Host "  Product Version: $($info.ProductVersion)"
                        $found = $true
                    }
                } catch {
                    # Ignore files without metadata
                }
            }

            if (-not $found) {
                Write-Host "No executable files found with metadata matching '$searchTerm'."
            }
        }
        elseif ($choice -eq "10") {
            Write-Host "`nScanning for Authenticode signature status..."

            Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.Extension -match "\.exe$|\.dll$" } | ForEach-Object {
                $signature = Get-AuthenticodeSignature $_.FullName
                if ($signature.Status -ne 'Valid') {
                    Write-Host "`nInvalid or missing signature for file: $($_.FullName)"
                    Write-Host "  Status: $($signature.Status)"
                }
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
