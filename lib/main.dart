import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:users_app/authentication/signup_screen.dart';
import 'package:users_app/pages/map_screen.dart';
import 'package:users_app/splash_screen/splash.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionManager.requestLocationPermission();



  PermissionManager();
  // Firebase başlatılıyor
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCJyfiuKLbutjuG3NDXMQyPkf2D5OjkCFE',
      appId: 'id',
      messagingSenderId: 'sendid',
      projectId: 'myapp',
      storageBucket: 'com.petacode.usersapp',
    ),
  );

  // Uygulama çalıştırılıyor
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
      routes: {
        '/signup': (context) => const MyMapScreen(),
      },
    );
  }
}

class PermissionManager {
  // Konum iznini kontrol etmek için bu fonksiyonu kullanın.
  static Future<bool> checkLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  // Konum izni istemek için bu fonksiyonu kullanın.
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}
