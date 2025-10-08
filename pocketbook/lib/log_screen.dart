import 'package:flutter/material.dart';
import 'package:pocketbook/database_handler.dart';

//hardcoded data for testing asthetics until database is connected
class LogEntry {
final String date;
final String where;
final double amount;

LogEntry({required this.date, required this.where, required this.amount});
}

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {


final DatabaseHandler db = DatabaseHandler.databaseInstance!;
List<LogEntry> logs = [];

@override
void initState() {
  super.initState();
  listLogs();
  }

//list the logs from database <--------------------------------------------------
  Future<void> listLogs() 
  async{
    final dataLog = await db.getSpendingLog(DatabaseHandler.userID);
   
    setState(() {
      logs = dataLog.map((log) => LogEntry(
        //had to do null checks////need to fix database for null checks also<----------------
        date: log['date_time']?.toString() ?? 'No Date',
        where: log['caption']?.toString() ?? 'Unknown',
        amount: log['amount'] as double? ?? 0.0, 
      )
      ).toList();
    });
  
  }

   @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 222, 222),
      appBar: AppBar( 
        title: const Text('Log'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go Back',
          onPressed: () {
            Navigator.of(context).pop();
          }, 
        ),
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
      ),

      body: Column(
      
        children: [
          //Table for displaying titles//
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
                    textAlign: TextAlign.center,
                    ),
                ),
                   Expanded (
                 flex: 1,
                  child: Text(
                    'Amount', style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right
                    ), 
                ),

              ],)
          ),
          //List for displaying logs
          Divider(height: 1, color: const Color.fromARGB(255, 0, 0, 0)),
          Expanded(
            child: 
              logs.isEmpty ? const Center(child: Text('No transactions available.')) :
              ListView.builder(
              //change to data from database <----------------------------------
            itemCount: logs.length,
            itemBuilder: (context, index){

              final log = logs[index];
              final depositPos = log.amount > 0;
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