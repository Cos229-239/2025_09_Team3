import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:GestureDetector(
        onTap: () {
          print('screen tapped'); // TODO: replace with move to home screen
        },
        
        child: Scaffold(
          body: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 200,
            children: [
              Text('Welcome to PocketBook',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                ),
              ),
              Text('Tap anywhere to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                )
              )
            ],
            
          ),
        ),
      )  
    );
  }
}