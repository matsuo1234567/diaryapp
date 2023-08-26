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
              SizedBox(height: 16),
              Text('Notification', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isNotificationOn = true;
                      });
                    },
                    child: Text('ON'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          isNotificationOn ? Color(0xffE49B5B) : Colors.grey,
                      elevation: isNotificationOn ? 2 : 0,
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isNotificationOn = false;
                      });
                    },
                    child: Text('OFF'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          !isNotificationOn ? Color(0xffE49B5B) : Colors.grey,
                      elevation: !isNotificationOn ? 2 : 0,
                    ),
                  ),
                ],
              ),
              if (isNotificationOn)
                TextFormField(
                  decoration: InputDecoration(
                    hintText: '通知時間',
                  ),
                ),
              SizedBox(height: 16),
              Text('AI Settings', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: '名前(AI)',
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
                  hintText: '一人称',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '性格',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '短所',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '好きなもの',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '嫌いなもの',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '備考',
                ),
                maxLines: 3,
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
