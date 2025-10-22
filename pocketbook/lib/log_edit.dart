import 'package:flutter/material.dart';
import 'package:pocketbook/database_handler.dart';
import 'package:pocketbook/helper_files.dart';
import 'package:pocketbook/log_screen.dart';
import 'package:intl/intl.dart';

//TODO: This just a copy of the category create screen. Remove unneccesary code, 
class LogEdit extends StatefulWidget {
  //allows for editing categories
  final LogEntry? selectedLog;
  const LogEdit({super.key, this.selectedLog});

  @override
  State<LogEdit> createState() => _LogEditState();
}

class _LogEditState extends State<LogEdit> {
  String dateVar = 'Select Date';
  late String dateString;
  late DateTime initialDateVar = DateFormat("MMM-dd-yyyy").parse(widget.selectedLog!.dateAndTime);
  bool isDeposit = true;
  
  @override
  void initState() {
    super.initState();
    //allows for Prefilling of fields when editing
    if (widget.selectedLog != null) {
      dateString = widget.selectedLog!.dateAndTime.replaceAll('\n', '\\');
      _captionController.text = widget.selectedLog!.caption;
      _amountController.text =widget.selectedLog!.amount.abs().toStringAsFixed(2);
      _amountValue = widget.selectedLog!.amount;
      _dateController = DateFormat("MMM-dd-yyyy").parse(widget.selectedLog!.dateAndTime);
    }
    if (_amountValue < 0) {
      isDeposit = false;
    }
  }
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  double _amountValue = 0.0;
  DateTime _dateController = DateTime.now();
  final DatabaseHandler db = DatabaseHandler.databaseInstance!;
  late String timeString = (dateString.substring(12)); //This code is a disaster, feel free to try and optimize :)

//for saving edited categories
    void saveEditedLog() async {
    String caption = _captionController.text;
    String dateTime = "${DateFormat("MMM-dd-yyyy").format(_dateController)}\n$timeString";

    if (caption.isEmpty || _amountController.text.isEmpty) {
      showErrorSnackBar(context, 'Please enter all fields');
      return;
    }
      

      
    
    try {

      double parsed = double.parse(_amountController.text);
      if (!isDeposit){
        _amountValue = -parsed.abs();
      }
      else{
        _amountValue = parsed.abs();
      }
      caption = firstLetterCapital(caption);

      //for calculating balance changes 
      double oldAmount =widget.selectedLog!.amount;
      double newAmount =_amountValue;
      double difference =newAmount - oldAmount;

      final userData= await db.getUserData(DatabaseHandler.userID);
      double currentBalance = 0.0;
      if(userData.isNotEmpty && userData.first['account_balance'] != null){
        currentBalance = userData.first['account_balance'] as double;
      }
      double updatedBalance = currentBalance + difference;
      await db.setUserBalance(DatabaseHandler.userID, updatedBalance);
      
      await db.updateLogs(DatabaseHandler.userID, widget.selectedLog!.category, widget.selectedLog!.caption, caption, _amountValue, widget.selectedLog!.dateAndTime, dateTime);
      showErrorSnackBar(context, 'Log updated Successfully');
      Navigator.of(context).pop();
    
      
    } catch (e) {
      showErrorSnackBar(context, 'Please enter a valid amount');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color.fromARGB(255, 200, 200, 200),
 
      appBar: AppBar(
        title: const Text('Edit Log'),
        centerTitle: true,
        backgroundColor: const Color(0xFF280039),
        foregroundColor: Colors.white,
        elevation: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back Icon',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Container(
                width: 300,
                height: 525,
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
                        'Edit Log',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF280039),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _captionController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Caption',
                          hintText: 'Enter caption',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF3B0054),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 117, 20, 158),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                         controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          signed: false,
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Amount',
                          hintText: 'Enter amount',
                          enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3B0054),
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 117, 20, 158),
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            try{
                              double parsed =double.parse(value);
                              if (!isDeposit)
                              {
                                _amountValue = -parsed.abs();
                              }
                              else
                              {
                                _amountValue = parsed.abs();
                              }
                            }catch(e){
                              _amountValue = 0.0;
                            }
                            
                          });
                        },
                      ),
                      
                      SizedBox(height: 30),
                      // calendar -- only change date
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: initialDateVar,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now()
                          );
                          if (picked != null)
                          {
                            _dateController = picked;
                          }
                          setState(() {
                            dateVar = DateFormat("MMM-dd-yyyy").format(_dateController);
                            initialDateVar = _dateController;
                          });
                        },
                        child: Text(dateVar)),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // updated to save edited categories
                          if (widget.selectedLog != null) {
                            saveEditedLog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, 
                          foregroundColor: Colors.black,
                        ),
                        
                        child: const Text('Save')
                      ),
                      if(widget.selectedLog !=null)
                      const SizedBox(height: 15),
                      if(widget.selectedLog !=null)
                      ElevatedButton(
                        onPressed: () 
                        async {
                          //dailog box to confirm deletion
                          bool? deleteConfirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: Text('Are you sure you would like to continue with the deletion of log \""${widget.selectedLog!.caption}"\"? This action cannot be undone.'),
                                actions:[
                                  TextButton(
                                    onPressed:() => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),

                                  TextButton(
                                    onPressed:() => Navigator.of(context).pop(true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red),),
                                  ),
                                ]
                              );
                            }

                          );

                          if (deleteConfirm == true) {
                          await db.deleteLog(
                           //Update functionality to update account balance when deleting a log
                            DatabaseHandler.userID, widget.selectedLog!.caption, widget.selectedLog!.dateAndTime);
                            Navigator.of(context).pop();
                          
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 17, 0), 
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete Log'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ]
      )
    );
  }
}