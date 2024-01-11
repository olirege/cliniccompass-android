// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCPB0IzIKVmWUC51GnQlNTDuJzRW-KFv0s',
    appId: '1:456885719738:web:3aad2ec26796cc603ee883',
    messagingSenderId: '456885719738',
    projectId: 'cliniccompass-9cf0c',
    authDomain: 'cliniccompass-9cf0c.firebaseapp.com',
    storageBucket: 'cliniccompass-9cf0c.appspot.com',
    measurementId: 'G-F00P4Y4KHR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJCRv_FtbPhjJTyCFhGe2ReFfg2y-tqiY',
    appId: '1:456885719738:android:5c3655e04c2a4c523ee883',
    messagingSenderId: '456885719738',
    projectId: 'cliniccompass-9cf0c',
    storageBucket: 'cliniccompass-9cf0c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD7TGfFz29Z7lojgnG2pN16NEm1wdasZ9o',
    appId: '1:456885719738:ios:5533034aa8db38053ee883',
    messagingSenderId: '456885719738',
    projectId: 'cliniccompass-9cf0c',
    storageBucket: 'cliniccompass-9cf0c.appspot.com',
    iosBundleId: 'com.example.counter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD7TGfFz29Z7lojgnG2pN16NEm1wdasZ9o',
    appId: '1:456885719738:ios:ed32a853bbe273133ee883',
    messagingSenderId: '456885719738',
    projectId: 'cliniccompass-9cf0c',
    storageBucket: 'cliniccompass-9cf0c.appspot.com',
    iosBundleId: 'com.example.counter.RunnerTests',
  );
}