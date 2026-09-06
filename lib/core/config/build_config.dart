/// FILE: lib/core/config/build_config.dart

class BuildConfig {
  /// Compile-time constant flag indicating whether the build is a Store-Safe Android APK (e.g. Samsung Galaxy Store).
  /// Built via `flutter build apk --dart-define=IS_STORE_BUILD=true` or set to false for Web PWA.
  static const bool isStoreBuild = bool.fromEnvironment('IS_STORE_BUILD', defaultValue: false);

  /// Official Web Platform (.io URL) where users activate their account and complete purchase via Stripe.
  static const String webPlatformUrl = 'https://appdeveloper365.github.io/OmniToolkit-app';

  /// Store-Safe compliance message for locked overlay screens when IS_STORE_BUILD is true.
  static const String storeComplianceLockMessage = 
      'Premium account required. Please log in using an account activated on our official web platform (.io URL).';
}
