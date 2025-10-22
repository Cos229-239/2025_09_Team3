import 'package:flutter/material.dart';
import 'package:pocketbook/database_handler.dart';
import 'package:pocketbook/log_edit.dart';

//hardcoded data for testing asthetics until database is connected
class LogEntry {
  String category;
  String caption;
  double amount;
  String dateAndTime;

  LogEntry({
    required this.category,
    required this.caption,
    required this.amount,
    required this.dateAndTime,
  });
}

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {


final DatabaseHandler db = DatabaseHandler.databaseInstance!;
List<LogEntry> logs = [];
List<LogEntry> logFilters = [];
String selectedFilter = 'All';

final List<String> filterOptions =[
  'All',
  'Expenses',
  'Deposits',
  'Ascending Date',
  'Descending Date',
  'Ascending Amount',
  'Descending Amount',

 ];


void reloadPage() {
    setState(() {
      
    });
    listLogs();
  }

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
        //had to do null checks////need to fix database for null checks also<---------------- //Lucas here - Database nulls are on purpose, just a heads up. I dont think nulls are possible if they shouldnt be. Let me know if I missed something though
        dateAndTime: log['date_time']?.toString() ?? 'No Date',
        caption: log['caption']?.toString() ?? 'Unknown',
        amount: log['amount'] as double? ?? 0.0,
        category: log['category']?.toString() ?? ''
      )).toList();
    });
  
  }

  //method to filter logs
  void applyLogFilters(){
    setState((){
      switch (selectedFilter){
        case 'All':
          logFilters = List.from(logs);
          break;
        case 'Expenses':
         logFilters = logs.where((log) => log.amount <0).toList();
         break;
        case 'Deposits':
         logFilters = logs.where((log) => log.amount >0).toList();
         break;
        case 'Ascending Date':
         break;
        case 'Descending Date':
          break;
        case 'Ascending Amount':
          break;
        case 'Descending Amount':
          break;
        default:
        logFilters = List.from(logs);
      }

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
              return ElevatedButton(
                onPressed: () {
                   Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LogEdit(selectedLog: log),
                    ),
                  ).then((value) => reloadPage());
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: LinearBorder.bottom(
                    side: const BorderSide(
                      color: Colors.black
                    )
                  )
                ),
               
                 child: Row(
                  children: [
                    Expanded(
                      child: Text (log.dateAndTime,
                        textAlign: TextAlign.left, 
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text (log.caption,
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.black),
                       ),
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