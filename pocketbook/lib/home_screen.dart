import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userName = "PLACEHOLDER";
    double balance = 0;

    return Scaffold(
      backgroundColor: Color(0xFF3B0054),
      appBar: AppBar( //Top bar across screen
        title: Text('PocketBook'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings),
          tooltip: 'Setting Icon',
          onPressed: () {}, //TODO: Assign button actions
        ),
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(30), //Welcome Message
            child: Text('Hi, $userName!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding:EdgeInsets.symmetric(horizontal: 10), //Balance section outer border
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container( //Balance section content
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9B71),
                    border: Border.all(
                      color: Color(0xFF3B0054),
                      width: 3,                    
                    ),
                    borderRadius: BorderRadius.circular(7)
                  ),
                  child: Center(
                    child: Text(
                      'Account Balance\n\$$balance',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),  
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,), //Spending Section padding
            child: Center(
              child: Container( //spending section outer border
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container( //Spending section content
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9B71),
                    border: Border.all(
                      color: Color(0xFF3B0054),
                      width: 3,                    
                    ),
                    borderRadius: BorderRadius.circular(7)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.only(
                        bottom: 15
                        ),
                        child: Text(
                          'Add Spending',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),  
                          ),
                        ),
                      ),
                      
                      Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Amount',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color:  Color(0xFF3B0054), width: 3),
                              borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 117, 20, 158), width: 3),
                              borderRadius: BorderRadius.circular(15)),
                          ),
                          keyboardType: TextInputType.number
                        ),
                      ),
                      Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Caption',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color:  Color(0xFF3B0054), width: 3),
                              borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 117, 20, 158), width: 3),
                              borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      //DropdownMenu<>(),
                      Row (
                        children: [
                          Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
                            child: SizedBox(
                              width: 250,
                              child: TextField(
                                
                                decoration: InputDecoration(
                                  
                                  border: OutlineInputBorder(),
                                  hintText: '[placeholder for dropdown]',
                                ),
                              ),
                            ),
                            
                          ),
                          IconButton.filled( //TODO: Match fill color with background
                            onPressed: () {}, 
                            icon: Icon(Icons.add),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ), 
                ),
              ),
            ),
          ),
          Expanded(
            child: Container()
          ),
          Row(
            children: [ //Navigation buttons
              Expanded(child: Container(),),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    IconButton.filled(onPressed: () {}, icon: Icon(Icons.add), style: IconButton.styleFrom(fixedSize: Size(60, 60))),
                    Text('Categories', style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    IconButton.filled(onPressed: () {}, icon: Icon(Icons.add), style: IconButton.styleFrom(fixedSize: Size(60, 60))),
                    Text('Spending', style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    IconButton.filled(onPressed: () {}, icon: Icon(Icons.add), style: IconButton.styleFrom(fixedSize: Size(60, 60))),
                    Text('Log', style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),      
            ],
          ),
          Padding(padding: EdgeInsetsGeometry.all(10),),
        ],
      ),
    );
  }
}

class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenStateManager();
}

class _HomeScreenStateManager extends State<HomeScreenState> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
