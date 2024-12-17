import 'package:flutter/material.dart';
import 'package:text_recognition_goolge_ml_kit/textrecognition/text.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TextRecognitionScreen(),
    );
  }
}
