import 'package:flutter/material.dart';


//hardcoded data for testing asthetics until database is connected
class FakeLog {
final String date;
final String where;
final double amount;

FakeLog({required this.date, required this.where, required this.amount});
}

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

//fake database list/getter <-----------Get rid of this when connected to database
List<FakeLog> getFakeDatabase(){
  return [
    FakeLog(date: '2023-10-01', where: 'Grocery Store', amount: -45.67),
    FakeLog(date: '2023-10-02', where: 'Coffee Shop', amount: -4.50),
    FakeLog(date: '2023-10-03', where: 'Restaurant', amount: -78.90),
    FakeLog(date: '2023-10-04', where: 'Gas Station', amount: 30.00),
    FakeLog(date: '2023-10-05', where: 'Online Shopping', amount: 120.45),
    FakeLog(date: '2023-10-06', where: 'Pharmacy', amount: 15.20),
    FakeLog(date: '2023-10-07', where: 'Bookstore', amount: -22.30),
    FakeLog(date: '2023-10-08', where: 'Clothing Store', amount: 60.00),
    FakeLog(date: '2023-10-09', where: 'Electronics Store', amount: 250.75),
    FakeLog(date: '2023-10-10', where: 'Gym Membership', amount: 35.00),
  ];
}

   @override
  Widget build(BuildContext context) {
    final dataLog = getFakeDatabase(); //pulls all data from database
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 222, 222),
      appBar: AppBar( 
        title: const Text('Log'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go Back',
          onPressed: () {}, 
        ),
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
      ),

      body: Column(
      
        children: [
          //Table for displaying titles
          Container(
            color: Colors.grey,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const[
                Expanded (
                  flex: 1,
                  child: Text(
                    'Date', style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                   Expanded (
                  flex: 1,
                  child: Text(
                    'Where', style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ),
                   Expanded (
                 flex: -3,
                  child: Text(
                    'Amount', style: TextStyle(fontWeight: FontWeight.bold),
                    ), 
                ),

              ],)
          ),
          //List for displaying logs
          Divider(height: 1, color: const Color.fromARGB(255, 0, 0, 0)),
          Expanded(
            child: ListView.builder(
              //change to data from database <----------------------------------
            itemCount: dataLog.length,
            itemBuilder: (context, index){
            
              final log = dataLog[index];
              final depositPos = log.amount >= 0;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide (color: const Color.fromARGB(255, 0, 0, 0))
                  )
                 ),
                 child: Row(
                  children: [
                    Expanded(
                      
                      child: Text (log.date,
                      textAlign: TextAlign.left),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text (log.where
                        , textAlign: TextAlign.center,),
                      // Add this)
                    ),
                    Expanded(
                      
                      child: Text (
                         textAlign: TextAlign.right,
                        //operator to determine if deposit or withdrawal
                        (depositPos ? '+' : '') + '\$' + log.amount.toStringAsFixed(2),
                        style: TextStyle(
                         
                          color: depositPos ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          
                        )
                      ),
                    ),
                  ],
                  ),
                );
              }
            )
          )
          
          
        ],
      )
    );
  }
}