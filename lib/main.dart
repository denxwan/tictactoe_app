// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'game_page.dart';
import 'login_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAveOcEOHk1aoKPon2Z5Mby146UnTePSiA",
          authDomain: "tictactoe-project-795ad.firebaseapp.com",
          projectId: "tictactoe-project-795ad",
          storageBucket: "tictactoe-project-795ad.appspot.com",
          messagingSenderId: "1011729409274",
          appId: "1:1011729409274:web:926dd88c34b7d89572d543"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: LoginPage(),
      ///*
      home: GamePage(
        currentCode: '1234567',
      ),
      //*/
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
