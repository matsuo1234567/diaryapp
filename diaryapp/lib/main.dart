import 'package:diaryapp/header.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  // コンストラクタの修正
  MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(  // constを取り除いた
      home: Scaffold(
        appBar: Header(),  // constを取り除いた
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}


