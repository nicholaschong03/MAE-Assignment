// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyCgcmJMW08JZHjU4HpnefjiTApdhXu3iIg',
    appId: '1:768333745626:web:2faea292dde440c78984e3',
    messagingSenderId: '768333745626',
    projectId: 'mae-assignment-d12c8',
    authDomain: 'mae-assignment-d12c8.firebaseapp.com',
    storageBucket: 'mae-assignment-d12c8.appspot.com',
    measurementId: 'G-4V47YG839M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVARTYK4QbCtaffqd8Sv6PmEZ6FU5Jjv0',
    appId: '1:768333745626:android:e43fbd15d8e3569c8984e3',
    messagingSenderId: '768333745626',
    projectId: 'mae-assignment-d12c8',
    storageBucket: 'mae-assignment-d12c8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcXknqG16WObWol10EJ6Eo0hRhNkjDJvA',
    appId: '1:768333745626:ios:e228a156917d6f7c8984e3',
    messagingSenderId: '768333745626',
    projectId: 'mae-assignment-d12c8',
    storageBucket: 'mae-assignment-d12c8.appspot.com',
    iosBundleId: 'com.example.jomEatProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDcXknqG16WObWol10EJ6Eo0hRhNkjDJvA',
    appId: '1:768333745626:ios:e228a156917d6f7c8984e3',
    messagingSenderId: '768333745626',
    projectId: 'mae-assignment-d12c8',
    storageBucket: 'mae-assignment-d12c8.appspot.com',
    iosBundleId: 'com.example.jomEatProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCgcmJMW08JZHjU4HpnefjiTApdhXu3iIg',
    appId: '1:768333745626:web:a727c8000c20fff58984e3',
    messagingSenderId: '768333745626',
    projectId: 'mae-assignment-d12c8',
    authDomain: 'mae-assignment-d12c8.firebaseapp.com',
    storageBucket: 'mae-assignment-d12c8.appspot.com',
    measurementId: 'G-3M6F7D6LCG',
  );
}
