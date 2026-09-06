# Powershell Automated Deployment Script (deploy-all.ps1)
Param(
    [string]$CommitMessage = "Automated dual build deployment: Web PWA & Store-Safe Android APK"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "STEP 1: Running Automated Test Suite..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
flutter test --concurrency=1

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 2: Compiling Web PWA (IS_STORE_BUILD = false)..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
flutter build web --release --base-href "/OmniToolkit-app/"

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 3: Compiling Store-Safe APK (IS_STORE_BUILD = true)..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
flutter build apk --release --dart-define=IS_STORE_BUILD=true

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 4: Moving APK to Public Downloads Directory..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
New-Item -ItemType Directory -Path "public/downloads" -Force | Out-Null
Copy-Item -Path "build/app/outputs/flutter-apk/app-release.apk" -Destination "public/downloads/productivity-radio.apk" -Force
Copy-Item -Path "build/app/outputs/flutter-apk/app-release.apk" -Destination "build/web/downloads/productivity-radio.apk" -Force

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 5: Deploying Web Build to gh-pages Branch..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Copy-Item -Path "build/web/*" -Destination "../omnitoolkit-gh-pages" -Recurse -Force
git -C "../omnitoolkit-gh-pages" add .
git -C "../omnitoolkit-gh-pages" commit -m "Deploy Web PWA and downloadable Store APK ($CommitMessage)"
git -C "../omnitoolkit-gh-pages" push origin gh-pages

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 6: Committing Source & Pushing to Main Branch..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
git add .
git commit -m "$CommitMessage"
git push origin feature/remove-weather-module

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "SUCCESS: Dual Build & Deployment Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
