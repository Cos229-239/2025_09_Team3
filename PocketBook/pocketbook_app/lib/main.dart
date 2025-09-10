import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  const App({super.key});
  
@override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'PocketBook App!',
      theme: ThemeData(primarySwatch:Colors.deepPurple),
      home: HomePage(),

    );
  
  }

}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PocketBook'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

}