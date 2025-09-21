import 'package:flutter/material.dart';
import 'package:pocketbook/categories_screen.dart';
import 'package:pocketbook/home_screen.dart';
import 'package:pocketbook/categories_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
<<<<<<< HEAD
          MaterialPageRoute(builder: (context) => const HomeScreenState()),
=======
          MaterialPageRoute(builder: (context) => const HomeScreen()),
>>>>>>> categories
        );
      },

      child: Scaffold(
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 200,
          children: [
            Text(
              'Welcome to PocketBook',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 48),
            ),
            Text(
              'Tap anywhere to continue',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
