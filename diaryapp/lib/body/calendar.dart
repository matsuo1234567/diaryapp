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
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  //アプリの初期化時に呼び出される
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    //選択された日付に関するイベントのリストを保持する。
    //valuenotifierは値が変化するたびにwidgetを再構築可能
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
    print('success');

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

//stateオブジェクトが不要になった時に呼び出される
  @override
  //アプリの終了時に呼び出される
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

//特定の日付のイベントを取得するため
  List<Event> _getEventsForDay(DateTime day) {
    //与えられた日付に関するイベントリストを返す
    return kEvents[day] ?? [];
  }

//クリック時に呼び出し
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    //選択された日付と現在選択されている日付が同じ出ない時
    if (!isSameDay(_selectedDay, selectedDay)) {
      //Widgetの再構築がトリガー
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      final wantDay = _selectedDay!.toIso8601String().split('T')[0];
      //returnでdairyが返される
      final result = await getText(wantDay);

      setState(() {
        diary = result;
      });

      //選択された日に関するイベントリストを _getEventsForDayメソッドから取得し、
      //_selectedEventsの値を更新。
      //これで、表示されているイベントが選択された日に基づいて更新。
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

//あれですあれ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //ヘッダー
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xff5C9387)),
        elevation: 0,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "settings",
            style: TextStyle(color: Color(0xffE49B5B)),
          ),
        ),
        backgroundColor: const Color(0xffF6F7F9),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 25, left: 25, right: 25),
            child: TableCalendar<Event>(
              firstDay: kFirstDay, //カレンダー最初の日付
              lastDay: kLastDay, //カレンダー最後の日付
              focusedDay: _focusedDay, //現在の対象の日付
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
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
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          Text(diary),
          //日記の箱
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              //監視する値を設定
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          border:
                              Border.all(color: Color(0xFF7C9D96), width: 2),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1.0,
                              blurRadius: 2.0,
                              offset: Offset(0, 5),
                            )
                          ]),
                      child: ListTile(
                        //箱の内容
                        title: Text('${diary}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
