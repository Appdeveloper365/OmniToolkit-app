# OmniToolkit v1.0.0 - Windows & Web Release

## Overview

OmniToolkit is an offline-first daily utility suite for Windows and Web, featuring a prominent live **Calendar & Clock** with notes and date difference calculation, **3D Calculator & Unit Converter**, **World Radio Explorer**, **US Location & Area Code Lookup**, and a secure **Password Generator**.

## Release Highlights

- 🎨 **Unique 3D Logo Design** - Custom branding specific to OmniToolkit
- 🔒 **100% Offline-First** - All core features work without internet
- 🎵 **Radio Streaming** - World radio directory with direct playback
- 📱 **Cross-Platform** - Native Windows app (MSIX) and Progressive Web App (PWA)
- 🛡️ **Secure** - Password generator with local-only data storage
- 🎨 **Modern UI** - Material Design 3 with light/dark theme support

## Features

### 📅 Calendar & Live Clock
- Live dual 12h/24h digital clock display
- Country holidays & international observances
- Local SQLite date notes
- Date difference calculator

### 🧮 3D Calculator & Unit Converter
- Standard calculator operations
- Scientific mode with advanced functions
- Date math capabilities
- Unit converter with 6 categories:
  - Length (m, km, mi, ft, yd)
  - Weight (kg, g, lb, oz)
  - Temperature (°C, °F, K)
  - Volume (L, mL, gal, pt)
  - Area (m², km², mi², acres)
  - Energy (kJ, cal, Btu, Wh)

### 🎵 Radio Explorer
- World radio stream directory
- Direct audio playback
- Favorites management
- Country/genre directories
- Animated visualizer
- Native Windows audio support

### 📍 US Lookup
- 100% offline ZIP code lookup
- City/County/State finder
- Area code lookup
- Fuzzy search support
- Complete US geographic database

### 🔑 Password Generator
- Secure random password generation
- Customizable character sets
- Copy-to-clipboard support
- Session-only memory history

### ⚙️ Settings
- Theme selection (Light/Dark/System)
- Firebase Authentication (for data sync)
- User preferences storage

## Platform Support

### Windows
- **Format**: MSIX installer
- **Installation**: Microsoft Store or direct MSIX installation
- **Requirements**: Windows 10/11 with internet capability
- **Audio**: Native media_kit backend for high-quality radio streaming

### Web (Progressive Web App)
- **URL**: https://appdeveloper365.github.io/OmniToolkit-app/
- **Support**: Chrome, Firefox, Safari, Edge
- **Features**: Installable as standalone app, offline capability

### macOS
- **Support**: Native support via Flutter
- **Audio**: media_kit backend

### Linux
- **Support**: Native support via Flutter
- **Audio**: media_kit backend

## Installation

### Windows (MSIX)
1. Download the .msix file from releases
2. Double-click to install
3. Or submit to Microsoft Store

### Web
- Visit: https://appdeveloper365.github.io/OmniToolkit-app/
- Install as app via browser menu

## Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Audio**: just_audio + media_kit (Windows/Linux)
- **UI**: Material Design 3

## Build Instructions

`ash
# Install dependencies
flutter pub get

# Run code analysis
flutter analyze

# Run tests
flutter test

# Build Windows MSIX
flutter pub run msix:create

# Build Web PWA
flutter build web --release --base-href "/OmniToolkit-app/"
`

## Privacy & Security

- All local data stored in SQLite on your device
- Optional Firebase authentication for cloud sync
- See privacy policy in docs/privacy-policy.html
- No telemetry or user tracking

## Support

For issues, feature requests, or contributions, visit:
https://github.com/Appdeveloper365/OmniToolkit-app

## License

See LICENSE file in repository

---

**Version**: 1.0.0
**Release Date**: 2025
**Publisher**: BTIM
**Status**: Ready for Microsoft Store & Web deployment

