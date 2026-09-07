class BuildConfig {
  static const bool isStoreBuild =
      bool.fromEnvironment('IS_STORE_BUILD', defaultValue: false);

  static const String webPlatformUrl =
      'https://appdeveloper365.github.io/OmniToolkit-app';

  static const String storeComplianceLockMessage =
      'Premium account required. Please log in using an account activated on our official website.';
}
