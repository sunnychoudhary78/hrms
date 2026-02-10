import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-s2Ha3cg9DP68qyS8PcxAgfXWpAZS3ek',
    appId: '1:538918107222:android:43c1f1176a13c7a565e3f7',
    messagingSenderId: '538918107222',
    projectId: 'lmsmobileapp-32199',
    storageBucket: 'lmsmobileapp-32199.firebasestorage.app',
  );
}
