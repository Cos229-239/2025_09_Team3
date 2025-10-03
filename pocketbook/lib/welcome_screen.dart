import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbook/sign_in_screen.dart';
import 'package:pocketbook/home_screen.dart';
import 'package:pocketbook/database_handler.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    // Keep the splash visible for a moment so users see it
    await Future.delayed(const Duration(milliseconds: 1200));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logged_in') ?? false;
    final savedEmail = prefs.getString('email');

    if (isLoggedIn && savedEmail != null) {
      try {
        // Restore the user session (set static userID)
        await DatabaseHandler.databaseInstance!.setUserIDVar(savedEmail);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreenState()),
        );
        return;
      } catch (_) {
        // If anything fails, fall through to sign-in
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF280039),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'PocketBook',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}