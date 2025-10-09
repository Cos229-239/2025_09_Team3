import 'package:flutter/material.dart';
//This is a file to add helper functions for multiple screens to clean up code. 

//Function to capitalize first letter of each word
String firstLetterCapital(String input){

if(input.isEmpty) {
return input;
}
return input.split(' ').map((word){
  if (word.isEmpty) return word;
  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}).join(' ');
}

//helper for snackbar
void showErrorSnackBar(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
  );
}