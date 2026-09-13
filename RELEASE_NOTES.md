# OmniToolkit Windows MSIX Release Notes

## Product

This release is the native Windows application packaged as
`BTIM_OmniToolkit.msix`. It is not a wrapper for, redirect to, or embedded view
of a web application.

## Included modules

- Calendar and clock
- Calculator and unit converter
- Radio Explorer
- Offline ZIP and area-code lookup
- Password Generator
- Settings

## Runtime behavior

Core functionality and application data execute locally. Internet access is
used only when a user chooses to play a radio station directly from that
station's stream server.

## Excluded from this Windows release

- Google authentication
- Firebase client services
- Stripe and checkout
- WebView and external application launchers
- PWA installation, service-worker, and update behavior
- PWA share-target routing

## Build

```bash
flutter pub get
flutter analyze
flutter test
flutter pub run msix:create
```

Output: `build/msix/BTIM_OmniToolkit.msix`