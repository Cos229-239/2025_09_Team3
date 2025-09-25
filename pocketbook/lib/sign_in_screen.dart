import 'package:flutter/material.dart';
import 'package:pocketbook/account_creation.dart';
import 'package:pocketbook/home_screen.dart';
import 'package:pocketbook/database_handler.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

@override
State<SignInScreen> createState() => _SignInScreenState();
 
}

class _SignInScreenState extends State<SignInScreen> {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final DatabaseHandler db = DatabaseHandler.databaseInstance!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF280039),
      appBar: AppBar(
        title: const Text('PocketBook'),
        centerTitle: true,
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
        
        
      ),
      body: Center(
         
        child: Container(
          width: 300,
          height: 500,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9B71),
            border: Border.all(
              color: const Color(0xFF280039),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF280039),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField( //TODO: Change text-type to email
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton( //TODO: Check both fields are full
                  onPressed: () async {
                      if (await db.verifyUser(_emailController.text, _passwordController.text))
                      {
                        await db.setUserIDVar(_emailController.text);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const HomeScreenState()),
                        );
                      }
                      else
                      {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Incorrect email or password'),
                            actions: <Widget>[
                              TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: const Text('OK')),
                            ],
                          ),
                        );
                      }
                      
                  },
                  child: const Text('Sign In'),
                  style:  ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF280039),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'If you don\'t have an account, please sign up first.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                 const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AccountCreation()),
                    );
                  },
                  child: const Text('Sign Up'),
                  style:  ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF280039), 
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


