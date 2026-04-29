import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const String _androidApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const String _androidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const String _androidSenderId = String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID');
  static const String _androidProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _androidStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static const String _iosApiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');
  static const String _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const String _iosSenderId = String.fromEnvironment('FIREBASE_IOS_MESSAGING_SENDER_ID');
  static const String _iosProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _iosStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static bool get isConfigured => currentPlatform != null;

  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      default:
        return null;
    }
  }

  static FirebaseOptions? get _android {
    if (_missingRequiredValues([
      _androidApiKey,
      _androidAppId,
      _androidSenderId,
      _androidProjectId,
    ])) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _androidApiKey,
      appId: _androidAppId,
      messagingSenderId: _androidSenderId,
      projectId: _androidProjectId,
      storageBucket: _androidStorageBucket.isEmpty ? null : _androidStorageBucket,
    );
  }

  static FirebaseOptions? get _ios {
    if (_missingRequiredValues([
      _iosApiKey,
      _iosAppId,
      _iosSenderId,
      _iosProjectId,
    ])) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _iosApiKey,
      appId: _iosAppId,
      messagingSenderId: _iosSenderId,
      projectId: _iosProjectId,
      storageBucket: _iosStorageBucket.isEmpty ? null : _iosStorageBucket,
      iosBundleId: _iosBundleId.isEmpty ? null : _iosBundleId,
    );
  }

  static bool _missingRequiredValues(List<String> values) {
    return values.any((value) => value.trim().isEmpty);
  }
}
