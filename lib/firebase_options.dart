// ============================================================================
// Section: External Library Imports
// Imports Firebase Core options class and TargetPlatform utilities from Flutter Foundation.
// ============================================================================
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// ============================================================================
// Section: Firebase Configuration Class (`DefaultFirebaseOptions`)
// Static utility class providing platform-specific Firebase configuration objects.
// ============================================================================
class DefaultFirebaseOptions {
  // --------------------------------------------------------------------------
  // Sub-Block: Target Platform Selector (`currentPlatform`)
  // Inspects current platform target (Web, Android, iOS, macOS, Windows) and returns corresponding FirebaseOptions.
  // --------------------------------------------------------------------------
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Web Firebase Configuration Options
  // API key, App ID, Messaging Sender ID, Project ID, and Storage Bucket for Web.
  // --------------------------------------------------------------------------
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBEWNHwSIeF_XKwqB_BxnUFElpBoK8RIyU',
    appId: '1:134606677126:web:ddbe8aa2fd8b6ebfd0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    authDomain: 'chess-be462.firebaseapp.com',
    storageBucket: 'chess-be462.firebasestorage.app',
    measurementId: 'G-XDSZ5CLWZE',
  );

  // --------------------------------------------------------------------------
  // Sub-Block: Android Firebase Configuration Options
  // API key, App ID, Messaging Sender ID, Project ID, and Storage Bucket for Android.
  // --------------------------------------------------------------------------
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvdT0TiH96z517841Y2BE3MmGboldQW98',
    appId: '1:134606677126:android:f5fa6a9ef6068300d0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    storageBucket: 'chess-be462.firebasestorage.app',
  );

  // --------------------------------------------------------------------------
  // Sub-Block: iOS Firebase Configuration Options
  // API key, App ID, Messaging Sender ID, Project ID, Storage Bucket, and Bundle ID for iOS.
  // --------------------------------------------------------------------------
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5ojGDbdInAPe0FhG84PKYic4hRm2HJGA',
    appId: '1:134606677126:ios:c52359c30a0fb640d0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    storageBucket: 'chess-be462.firebasestorage.app',
    iosBundleId: 'com.example.chess',
  );

  // --------------------------------------------------------------------------
  // Sub-Block: macOS Firebase Configuration Options
  // API key, App ID, Messaging Sender ID, Project ID, Storage Bucket, and Bundle ID for macOS.
  // --------------------------------------------------------------------------
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA5ojGDbdInAPe0FhG84PKYic4hRm2HJGA',
    appId: '1:134606677126:ios:c52359c30a0fb640d0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    storageBucket: 'chess-be462.firebasestorage.app',
    iosBundleId: 'com.example.chess',
  );

  // --------------------------------------------------------------------------
  // Sub-Block: Windows Firebase Configuration Options
  // API key, App ID, Messaging Sender ID, Project ID, and Storage Bucket for Windows.
  // --------------------------------------------------------------------------
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBEWNHwSIeF_XKwqB_BxnUFElpBoK8RIyU',
    appId: '1:134606677126:web:2972e7bde0d0e1f8d0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    authDomain: 'chess-be462.firebaseapp.com',
    storageBucket: 'chess-be462.firebasestorage.app',
    measurementId: 'G-JDTWBZQGK9',
  );
}
