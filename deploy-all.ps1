# Powershell Automated Deployment Script (deploy-all.ps1)
Param(
    [string]$CommitMessage = "Automated dual build deployment: Web PWA & Store-Safe Android APK/AAB"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path "android/key.properties")) {
    throw "Missing android/key.properties. Generate or copy the release signing file before building Galaxy Store artifacts."
}
if (-not (Test-Path "android/app/google-services.json")) {
    throw "Missing android/app/google-services.json. Register com.omnitoolkit.app in Firebase and download google-services.json before building Galaxy Store artifacts."
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "STEP 1: Running Automated Test Suite..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
flutter test --concurrency=1

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 2: Compiling Web PWA (IS_STORE_BUILD = false)..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
flutter build web --release --base-href "/OmniToolkit-app/"

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 3: Compiling Store-Safe APK and AAB (IS_STORE_BUILD = true)..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
flutter build apk --release --dart-define=IS_STORE_BUILD=true
flutter build appbundle --release --dart-define=IS_STORE_BUILD=true

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 4: Preserving Static Legal Docs..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
if (Test-Path "docs") {
    New-Item -ItemType Directory -Path "build/web/docs" -Force | Out-Null
    Copy-Item -Path "docs/*" -Destination "build/web/docs" -Recurse -Force
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 5: Moving Android Store Artifacts to Public Downloads Directory..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
New-Item -ItemType Directory -Path "public/downloads" -Force | Out-Null
New-Item -ItemType Directory -Path "build/web/downloads" -Force | Out-Null
Copy-Item -Path "build/app/outputs/flutter-apk/app-release.apk" -Destination "public/downloads/productivity-radio.apk" -Force
Copy-Item -Path "build/app/outputs/bundle/release/app-release.aab" -Destination "public/downloads/productivity-radio.aab" -Force
Copy-Item -Path "build/app/outputs/flutter-apk/app-release.apk" -Destination "build/web/downloads/productivity-radio.apk" -Force
Copy-Item -Path "build/app/outputs/bundle/release/app-release.aab" -Destination "build/web/downloads/productivity-radio.aab" -Force

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 6: Deploying Web Build to gh-pages Branch..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Copy-Item -Path "build/web/*" -Destination "../omnitoolkit-gh-pages" -Recurse -Force
git -C "../omnitoolkit-gh-pages" add .
$ghPagesChanged = git -C "../omnitoolkit-gh-pages" status --porcelain
if ($ghPagesChanged) {
    git -C "../omnitoolkit-gh-pages" commit -m "Deploy Web PWA and downloadable Store APK/AAB ($CommitMessage)"
    git -C "../omnitoolkit-gh-pages" push origin gh-pages
} else {
    Write-Host "No GitHub Pages changes to commit." -ForegroundColor Yellow
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "STEP 7: Committing Source & Pushing Branch..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
git add .
$sourceChanged = git status --porcelain
if ($sourceChanged) {
    git commit -m "$CommitMessage"
    git push origin feature/remove-weather-module
} else {
    Write-Host "No source changes to commit." -ForegroundColor Yellow
}

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "SUCCESS: Dual Build & Deployment Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
