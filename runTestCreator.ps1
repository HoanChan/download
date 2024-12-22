$VERSION = [Version]::Parse("1.1.0")

$verURL1 = 'https://raw.githubusercontent.com/HoanChan/download/main/TestCreator.ver'
$verURL2 = 'https://github.com/HoanChan/download/raw/refs/heads/main/TestCreator.ver'
$verURL3 = 'https://hoanchan.github.io/download/TestCreator.ver'
$verUrls = @($verURL1, $verURL2, $verURL3)
$exeURL1 = 'https://raw.githubusercontent.com/HoanChan/download/main/TestCreator.exe'
$exeURL2 = 'https://github.com/HoanChan/download/raw/refs/heads/main/TestCreator.exe'
$exeURL3 = 'https://hoanchan.github.io/download/TestCreator.exe'
$exeUrls = @($exeURL1, $exeURL2, $exeURL3)

function CountDown {
    param (
        [string]$message,
        [int]$seconds
    )
    for ($i = $seconds; $i -gt 0; $i--) {
        Write-Host ("$message {0}s " -f $i) -NoNewline
        Start-Sleep -Seconds 1
        Write-Host "`r" -NoNewline
    }
}
function Download-FileFromUrls {
    param (
        [string[]]$Urls,
        [string]$DestinationPath
    )

    foreach ($url in $Urls) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $DestinationPath -ErrorAction Stop
            Write-Host "Downloaded file from: $url"
            return $true
        } catch {
            Write-Host "Failed to download file from: $url"
        }
    }

    Write-Host "Failed to download file from all URLs"
    return $false
}
function Read-FileFromUrls {
    param (
        [string[]]$Urls
    )

    foreach ($url in $Urls) {
        try {
            $response = Invoke-WebRequest -Uri $url -ErrorAction Stop
            Write-Host "Downloaded file from: $url"
            return $response.Content
        } catch {
            Write-Host "Failed to download file from: $url"
        }
    }

    Write-Host "Failed to download file from all URLs"
    return $false
}

write-host "The TestCreator $VERSION launcher says hello! Please wait a moment while I prepare everything."

$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$filePath = Join-Path -Path $currentDir -ChildPath "TestCreator.exe"

if (-not (Test-Path -Path $filePath)) {
    write-host "(1) TestCreator.exe not found. First-time setup. Downloading TestCreator.exe from GitHub"
    $downloaded = Download-FileFromUrls -Urls $exeUrls -DestinationPath $filePath
    if (-not $downloaded) {
        write-host "Error: Unable to download TestCreator.exe. Please check your internet connection and try again."
        CountDown -message "Exiting in" -seconds 15
        Exit
    }
    else{
        write-host "(2) TestCreator.exe downloaded. Next time you launch TestCreator, it will check for updates automatically. Launching TestCreator..."
    }
}
else{
    write-host "(1) TestCreator.exe found. Checking for updates..."
    $verFilePath = Join-Path -Path $currentDir -ChildPath "TestCreator.ver"
    $downloaded = Read-FileFromUrls -Urls $verUrls
    if (-not $downloaded) {
        write-host "Error: Unable to download TestCreator.ver. Please check your internet connection and try again."
        CountDown -message "Exiting in" -seconds 15
        Exit
    }

    write-host "(2) Comparing versions..."
    $remoteVer = [Version]::Parse($downloaded)
    if ($remoteVer -gt $VERSION) {
        write-host "(3) New version of TestCreator found. Downloading..."
        $exeFilePath = Join-Path -Path $currentDir -ChildPath "NewTestCreator.exe"
        $downloaded = Download-FileFromUrls -Urls $exeUrls -DestinationPath $exeFilePath
        if (-not $downloaded) {
            write-host "Error: Unable to download TestCreator.exe. Please check your internet connection and try again."
            CountDown -message "Exiting in" -seconds 15
            Exit
        }
        write-host "(4) New version downloaded. Updating TestCreator..."
        try {
            $backupFilePath = Join-Path -Path $currentDir -ChildPath "TestCreator.bak"
            Move-Item -Path $filePath -Destination $backupFilePath -Force
            Move-Item -Path $exeFilePath -Destination $filePath -Force
            write-host "(5) Update successful. Launching TestCreator..."
        } catch {
            write-host "Error: Unable to update TestCreator. Please check your permissions and try again."
            CountDown -message "Exiting in" -seconds 15
            Exit
        }
    }
    else{
        write-host "(3) TestCreator is up-to-date. Launching TestCreator..."
    }
}

Start-Process -FilePath $filePath
write-host "All done. Goodbye!"
CountDown -message "Exiting in" -seconds 15