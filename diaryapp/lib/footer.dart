import 'package:flutter/material.dart';
import 'body/chat.dart';
import 'body/setting.dart';
import 'body/calendar.dart';

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _Footer();
}

class _Footer extends State<Footer> {
  static const _body = [CalendarPage(), ChatRoom(), SettingsPage()];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _body[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: '',
                tooltip: 'calendar'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat), label: '', tooltip: 'chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: '', tooltip: 'setttings'),
          ],
          type: BottomNavigationBarType.fixed,
          iconSize: 33,
          selectedItemColor: const Color(0xFF5C9387),
        ));
  }
}
