import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketbook/home_screen.dart';
import 'package:pocketbook/spendings_screen.dart';
import 'package:pocketbook/welcome_screen.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PocketBook',
      theme: ThemeData(
        //colorScheme: ColorScheme.dark(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreenState(),
    );
  }
}
