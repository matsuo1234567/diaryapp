import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationOn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text('User', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '名前(ユーザー)',
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '誕生日',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(SettingsPage());
}
