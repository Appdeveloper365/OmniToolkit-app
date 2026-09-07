# OmniToolkit

OmniToolkit is an offline-first daily utility suite featuring a prominent live **Calendar & Clock** with notes and date difference calculation, **3D Calculator & Unit Converter**, **World Radio Explorer**, **US Location & Area Code Lookup**, and a secure **Password Generator**.

## Features

- 📅 **Calendar & Live Clock**: Live dual 12h/24h digital clock display, country holidays & international observances, local SQLite date notes, and date difference calculator.
- 🧮 **3D Calculator & Unit Converter**: Standard, Scientific, Date Math, and Unit Converter (Length, Weight, Temperature, Volume, Area, Energy, Storage).
- 🎵 **Radio Explorer**: World radio stream directory with direct audio playback, favorites management, country/genre directories, and animated visualizer.
- 📍 **US Lookup**: 100% offline data-driven ZIP, City, County, and Area Code lookup with fuzzy search.
- 🔑 **Password Generator**: Secure password generation with copy support and session-only memory history.

## Platform Support

- **Windows**: MSIX installer for Microsoft Store or direct installation
- **Web**: Progressive Web App at https://appdeveloper365.github.io/OmniToolkit-app/
- **macOS & Linux**: Native support via Flutter

## Installation

### Windows (Microsoft Store or MSIX)
1. Download the MSIX file from releases
2. Double-click to install, or
3. Submit to Microsoft Partner Center

### Web PWA
- Visit: https://appdeveloper365.github.io/OmniToolkit-app/
- Install as standalone app from your browser

## Development

`ash
flutter pub get
flutter analyze
flutter test
flutter run -d windows
`

## Build

`ash
# Web PWA
flutter build web --release --base-href "/OmniToolkit-app/"

# Windows MSIX
flutter pub run msix:create
`

## Privacy & Security

- All local data stored in SQLite on your device
- Optional Firebase authentication for cloud sync
- No telemetry or user tracking
- See privacy policy in docs/privacy-policy.html

## Support

For issues, feature requests, or contributions, visit:
https://github.com/Appdeveloper365/OmniToolkit-app

## License

See LICENSE file in repository

---

**Version**: 1.0.0  
**Publisher**: BTIM  
**Status**: Ready for Microsoft Store & Web deployment
