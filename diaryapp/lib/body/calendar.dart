import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'utils.dart';
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String diary = '';

  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  //APIのやつ
  Future<String> getText(String wantDay) async {
    final url = Uri.parse("http://10.0.2.2:8000/server/get_text/");

    final response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode({"date": wantDay}),
    );

    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final diary = data["diary"];

        debugPrint('Diary get successfully');
        return diary;
      } else {
        debugPrint('Diary get failed with status code ${response.statusCode}');
        return 'Error';
      }
    } catch (e) {
      debugPrint('Error get Diary: $e');
      return 'Error2';
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

//クリック時
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      //wantDayでAPIの日記を呼び出す
      final wantDay = _selectedDay!.toIso8601String().split('T')[0];
      //returnで日記が返される
      final result = await getText(wantDay);

      setState(() {
        diary = result;
      });

      if (diary == '') {
        _visible = false;
      } else {
        _visible = true;
      }

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xff5C9387)),
        elevation: 0,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "calendar",
            style: TextStyle(color: Color(0xffE49B5B)),
          ),
        ),
        backgroundColor: const Color(0xffF6F7F9),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 0, bottom: 25, left: 25, right: 25),
            child: TableCalendar<Event>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday, //月曜開始
              calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                      color: Color(0x63F29545), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                      color: Color(0xC7F29545), shape: BoxShape.circle)),
              onDaySelected: _onDaySelected,
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle:
                      TextStyle(color: Color(0xFF619C90), fontSize: 25)),
            ),
          ),
          //日記の箱
          Visibility(
            visible: _visible,
            child: Expanded(
              child: ValueListenableBuilder<List<Event>>(
                //監視する値を設定
                valueListenable: _selectedEvents,
                builder: (context, daiary, _) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        border: Border.all(color: Color(0xFF7C9D96), width: 2),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 1.0,
                            blurRadius: 2.0,
                            offset: Offset(0, 5),
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${diary}'),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
