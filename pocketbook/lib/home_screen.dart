import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PocketBook'),
        centerTitle: true,
       leading:  IconButton(
         icon: Icon(Icons.settings),
        tooltip: 'Setting Icon',
        onPressed: () {},
        ),
        backgroundColor: const Color.fromARGB(255, 59, 0, 101),
        foregroundColor: Colors.white,
        elevation: 40,
       

      ),
      body: Center(
        child:Container(
          width: 195,
          height: 250,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 193, 140, 18),
            borderRadius: BorderRadius.circular(10)
            
              ),
          child: const Center(
            child: Text(
              'Account Balance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),  
              )
          ),
        )
      ),
    ) );
  }
}

