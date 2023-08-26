import 'package:flutter/material.dart';

class Record extends StatelessWidget {
  const Record({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.brown,
      title: const Text('page1'),
      
    ),
    body: ElevatedButton(
      onPressed: (){                
        Navigator.pop(
        context,
        MaterialPageRoute(builder: (context) => const Record()),
        );
        },
      child: const Text('押してみて'),
      style: ElevatedButton.styleFrom(
        // MEMO: primary は古くなったので backgroundColor へ変更しました
        backgroundColor: Colors.green,
     ),
    ),
    );  
  }
}

