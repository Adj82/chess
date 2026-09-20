import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBEWNHwSIeF_XKwqB_BxnUFElpBoK8RIyU',
    appId: '1:134606677126:web:ddbe8aa2fd8b6ebfd0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    authDomain: 'chess-be462.firebaseapp.com',
    storageBucket: 'chess-be462.firebasestorage.app',
    measurementId: 'G-XDSZ5CLWZE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvdT0TiH96z517841Y2BE3MmGboldQW98',
    appId: '1:134606677126:android:f5fa6a9ef6068300d0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    storageBucket: 'chess-be462.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5ojGDbdInAPe0FhG84PKYic4hRm2HJGA',
    appId: '1:134606677126:ios:c52359c30a0fb640d0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    storageBucket: 'chess-be462.firebasestorage.app',
    iosBundleId: 'com.example.chess',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA5ojGDbdInAPe0FhG84PKYic4hRm2HJGA',
    appId: '1:134606677126:ios:c52359c30a0fb640d0dd07',
    messagingSenderId: '134606677126',
    projectId: 'chess-be462',
    storageBucket: 'chess-be462.firebasestorage.app',
    iosBundleId: 'com.example.chess',
  );

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
