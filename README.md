# OmniToolkit Windows (MSIX)

This source tree produces the native Windows application package:

- `BTIM_OmniToolkit.msix`

## Runtime scope

The Windows application is a local Flutter desktop application. Calendar notes,
settings, lookup data, calculator functionality, and password generation run
locally. Radio playback connects directly to a selected station's stream; it
never opens or embeds the OmniToolkit web application.

The Windows build contains no Google authentication, Firebase client,
Stripe checkout, WebView, PWA service-worker, PWA install prompt, web update
check, or external app-launch dependency.

## Build and verify

```bash
flutter pub get
flutter analyze
flutter test
flutter pub run msix:create
```

The generated package is `build/msix/BTIM_OmniToolkit.msix`.

## Product boundaries

The GitHub Pages PWA is a separate product and release surface. It is not a
runtime dependency of this MSIX package. PWA deployment assets and its
associated service-worker configuration remain under `web/` and
`.github/workflows/deploy.yml` only until moved to an independent PWA source
repository. See `MSIX_PWA_ISOLATION_AUDIT.md` for the ownership and migration
record.

## Support

Source and issue tracking: https://github.com/Appdeveloper365/OmniToolkit-app