write-host "Trình khởi động TestCreator xin chào bạn, chờ tí để mình chuẩn bị mọi thứ nhé!"

$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DownloadURL1 = 'https://raw.githubusercontent.com/HoanChan/download/main/TestCreator.exe'
$DownloadURL2 = 'https://raw.githubusercontent.com/HoanChan/download/main/TestCreator.exe'
$DownloadURL3 = 'https://hoanchan.github.io/download/TestCreator.exe'

$URLs = @($DownloadURL1, $DownloadURL2)
$RandomURL1 = Get-Random -InputObject $URLs
$RandomURL2 = $URLs -notmatch $RandomURL1 | Get-Random

$env:INFO = "Hello"
$env:PROGRAM = "TestCreator"
$rand = Get-Date -Format "yyyyMMdd"

$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\app_$rand.exe" } else { "$env:TEMP\app_$rand.exe" }
$NeedDownload = $true
if (Test-Path $FilePath){
    if((Get-Date) - (Get-Item $FilePath).CreationTime -gt (New-TimeSpan -Days 1)) {
        Get-Item $FilePath | Remove-Item # Xoá file
        $NeedDownload = $true
    }
    else {
        $NeedDownload = $false
    }
}
else {
    $NeedDownload = $true
}
try {
    if ($NeedDownload) {
        $response = Invoke-WebRequest -Uri $RandomURL1 -OutFile $FilePath
    }
    Start-Process $FilePath
}
catch {
    try {
        if ($NeedDownload) {
            $response = Invoke-WebRequest -Uri $RandomURL2 -OutFile $FilePath
        }
        Start-Process $FilePath
    }
    catch {
        if ($NeedDownload) {
            $response = Invoke-WebRequest -Uri $RandomURL3 -OutFile $FilePath
        }
        Start-Process $FilePath
    }
}
write-host "Xong rồi, dùng đi nhé. Bye!"
Start-Sleep -Seconds 1