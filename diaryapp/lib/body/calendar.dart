import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:diaryapp/Record.dart';

DateTime _focused = DateTime.now();
DateTime? _selected; //追記

class Calendar extends StatefulWidget {
  const Calendar({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Calendar> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: TableCalendar(
            firstDay: DateTime.utc(2022, 4, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selected, day);
            },
            onDaySelected: (selected, focused) {
              if (!isSameDay(_selected, selected)) {
                setState(() {
                  _selected = selected;
                  _focused = focused;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Record()),
                );
              }
            },
            focusedDay: _focused,
          ),
        ));
  }
}
