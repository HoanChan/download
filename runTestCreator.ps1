$VERSION = [Version]::Parse("1.1.1")
$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$filePath = Join-Path -Path $currentDir -ChildPath "TestCreator.exe"
$verFilePath = Join-Path -Path $currentDir -ChildPath "TestCreator.ver"

if (Test-Path -Path $verFilePath) {
    $VERSION = [Version]::Parse((Get-Content -Path $verFilePath))
}

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
write-host "The TestCreator $VERSION launcher says hello! Please wait a moment while I prepare everything."

$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path -Path $filePath)) {
    write-host "(1) TestCreator.exe not found. First-time setup. Downloading TestCreator.exe from GitHub"
    $downloaded = Download-FileFromUrls -Urls $exeUrls -DestinationPath $filePath
    if (-not $downloaded) {
        write-host "Error: Unable to download TestCreator.exe. Please check your internet connection and try again."
        CountDown -message "Exiting in" -seconds 15
        Exit
    }
    else{
        write-host "(2) TestCreator.exe downloaded."
        $downloaded = Download-FileFromUrls -Urls $verUrls -DestinationPath $verFilePath
        if (-not $downloaded) {
            write-host "Error: Unable to download TestCreator.ver. I will download it again next time."
        }
        else{
            write-host "TestCreator.ver downloaded."
        }
        write-host "It seems like everything is ready now."
        write-host "(4) Scanning for viruses and launching TestCreator..."
    }
}
else{
    write-host "(1) TestCreator.exe found. Checking for updates..."
    $downloaded = Download-FileFromUrls -Urls $verUrls -DestinationPath $verFilePath
    if (-not $downloaded) {
        write-host "Error: Unable to download TestCreator.ver. Please check your internet connection and try again."
        CountDown -message "Exiting in" -seconds 15
        Exit
    }

    write-host "(2) Comparing versions..."
    $remoteVer = [Version]::Parse((Get-Content -Path $verFilePath))
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
        # Try to move the new version to the old version's place 10 times
        for ($i = 1; $i -lt 11; $i++) {
            try {
                $backupFilePath = Join-Path -Path $currentDir -ChildPath "TestCreator.bak"
                Move-Item -Path $filePath -Destination $backupFilePath -Force
                Move-Item -Path $exeFilePath -Destination $filePath -Force
                write-host "Update successful."
                write-host "(5) Scanning for viruses and launching TestCreator..."
                break
            } catch {
                write-host "Error: Unable to update TestCreator. Please check your permissions or restart computer and try again."
                CountDown -message "$i/10 Retrying in " -seconds 15
                # kill all pprocesses named TestCreator.*
                try{
                    Get-Process | Where-Object { $_.ProcessName -like "TestCreator*" } | Stop-Process -Force
                }
                catch{
                    write-host "Error: Unable to kill TestCreator processes. Please close them manually and try again."
                }
            }
        }
    }
    else{
        write-host "TestCreator is up-to-date"
        write-host "(3) Scanning for viruses and launching TestCreator..."
    }
}

Start-Process -FilePath $filePath
write-host "All done. Goodbye!"
CountDown -message "Exiting in" -seconds 15