import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOLHEapoJA4mDFKzdyX872w066FGHhIIU',
    appId: '1:547053282951:android:c18f46f57ab23a0e08fa22',
    messagingSenderId: '547053282951',
    projectId: 'pic-2026',
    storageBucket: 'pic-2026.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOLHEapoJA4mDFKzdyX872w066FGHhIIU',
    appId: '1:547053282951:ios:xxxxxxxxxxxxxxxxxxxxx', // Placeholder, precisa do config do iOS
    messagingSenderId: '547053282951',
    projectId: 'pic-2026',
    storageBucket: 'pic-2026.appspot.com',
    iosBundleId: 'br.com.copperfio', // From google-services.json package_name
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBOLHEapoJA4mDFKzdyX872w066FGHhIIU',
    appId: '1:547053282951:web:xxxxxxxxxxxxxxxxxxxxx', // Placeholder, precisa do config da web
    messagingSenderId: '547053282951',
    projectId: 'pic-2026',
    authDomain: 'pic-2026.firebaseapp.com',
    storageBucket: 'pic-2026.appspot.com',
    measurementId: 'G-xxxxxxxxxxxx', // Placeholder
  );
}