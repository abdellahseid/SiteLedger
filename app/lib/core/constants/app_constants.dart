import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'SiteLedger';
  static const String appTagline = 'Construction Delivery Intelligence';
  
  // API URL resolution: Android emulator uses 10.0.2.2, Web and Desktop use localhost
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:4000';
    }
    // Mobile Android emulator vs local host
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:4000'
        : 'http://localhost:4000';
  }

  static const String currencyCode = 'ETB';
  static const String currencySymbol = 'ETB ';
}
