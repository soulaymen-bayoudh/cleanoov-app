import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return web; // Utilise config web pour Windows aussi
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAr392f0H8VIaYtbE0Rs2hz5dLc-mZjQfI',
    appId: '1:936029076848:web:58b8002d85f7313cd7e3b5',
    messagingSenderId: '936029076848',
    projectId: 'cleanoov-app-a33e3',
    authDomain: 'cleanoov-app-a33e3.firebaseapp.com',
    storageBucket: 'cleanoov-app-a33e3.firebasestorage.app',
    measurementId: 'G-S92M7P0BNG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4J1zhPOf4GyMP3wGt5Hhli15BHOxpAWw',
    appId: '1:936029076848:android:507d233c182e6b58d7e3b5',
    messagingSenderId: '936029076848',
    projectId: 'cleanoov-app-a33e3',
    storageBucket: 'cleanoov-app-a33e3.firebasestorage.app',
  );
}
