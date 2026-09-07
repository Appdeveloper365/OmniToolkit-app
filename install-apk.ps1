# OmniToolkit APK Installation Script

$adbPath = "C:\Users\bala\AppData\Local\Android\sdk\platform-tools\adb.exe"
$apkPath = "C:\temp\productivity-radio.apk"

Write-Host ""
Write-Host "OmniToolkit APK Installation" -ForegroundColor Green
Write-Host ""

if (-not (Test-Path $apkPath)) {
    Write-Host "ERROR: APK not found" -ForegroundColor Red
    exit 1
}

Write-Host "Installing: $apkPath" -ForegroundColor Cyan
$file = Get-Item $apkPath
Write-Host "Size: $([math]::Round($file.Length/1MB, 2)) MB"
Write-Host ""

Write-Host "Connected devices:"
& $adbPath devices
Write-Host ""

Write-Host "Installing APK..." -ForegroundColor Yellow
& $adbPath install $apkPath

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
