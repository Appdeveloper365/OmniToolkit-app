# MSIX / PWA Isolation Audit

**Scope:** the Windows MSIX runtime source as of 2026-09-07.

## Windows runtime result

The MSIX application has no source import or dependency for Firebase,
Stripe, `url_launcher`, WebView, Google Sign-In, payment screens, or the PWA
share-target screen. It defines no route that targets the GitHub Pages PWA.
The Windows plugin registry contains only the local media-kit audio plugin and
JNI support; it contains no Firebase or URL-launcher registration.

The application starts at `MainNavigation` after local timezone, bundled asset,
and desktop audio initialization. It remains usable if GitHub Pages is offline.
Radio audio still needs network access to the radio station selected by the
user; that is unrelated to the PWA.

## Remaining matching references

| Location | Reference / purpose | MSIX runtime status | Required action |
|---|---|---|---|
| `.github/workflows/deploy.yml` | Builds and publishes the GitHub Pages PWA with `/OmniToolkit-app/` base href | Not included in MSIX | Move to the standalone PWA repository when that repository is created. |
| `web/index.html`, `web/manifest.json`, `web/service-worker.js`, `web/sw.js` | PWA bootstrap, manifest, service worker, and GitHub Pages download-cache path | Not included in MSIX | Retain only for the PWA; move with the PWA project. |
| `functions/index.js`, `functions/package.json`, `functions/package-lock.json` | PWA Stripe callable, webhook, and its GitHub Pages success/cancel URLs | Not included in MSIX | Retain only for the PWA; deploy/configure separately and move out of the MSIX source repository. |
| `docs/privacy-policy.html` | Shared published legal page; includes a GitHub repository support link and describes PWA hosting | Not opened by the MSIX application | Split into PWA and MSIX legal documents before either store submission. The repository link is an allowed external support link, not an app redirect. |
| `CLEANUP_REPORT.md`, `COMPREHENSIVE_RELEASE_SUMMARY.md`, `FINAL_VERIFICATION_CHECKLIST.md` | Historical release records containing outdated PWA/Firebase/Stripe statements | Not included in MSIX | Archive outside active release documentation or correct before distribution. |
| `README.md` | External GitHub source/support link | Not included in MSIX | Retain as documentation only. It does not link the application to the PWA. |
| `assets/data/curated_us_zips.csv`, `curated_us_zips.csv` | Textual town name `Deepwater`; matched the broad `WebView` search only as a false positive | Local app data | No action. |

## Removed from the MSIX runtime

- `lib/firebase_options.dart`
- `lib/core/config/build_config.dart` (contained the GitHub Pages URL)
- `lib/screens/pricing_screen.dart`
- `lib/screens/payment_success_screen.dart`
- `lib/screens/payment_cancelled_screen.dart`
- `lib/screens/share_target_screen.dart`
- `test/share_target_test.dart`
- Firebase/Cloud Functions/URL launcher dependencies and their Windows plugin registrations
- `/pricing`, `/payment-success`, `/payment-cancelled`, and `/share` routes
- Settings entry point for premium checkout

## Deliberate boundary

This repository still contains both release surfaces, so it is not yet a
physical two-repository split. However, the generated MSIX has no executable
path to the PWA or checkout backend. The remaining PWA files are build-time
assets for the web product only, and must be moved as a follow-up repository
split to achieve complete source-repository isolation.