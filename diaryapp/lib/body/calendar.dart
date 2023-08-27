import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'utils.dart';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  //try
  String? newdiary; //管理したい内容を設定
  //

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
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    //選択された日付と現在選択されている日付が同じ出ない時
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        //Widgetの再構築がトリガー
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
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
    //try
    print("$newdiary");
    //

    return Scaffold(
      //ヘッダー
      appBar: AppBar(
        toolbarHeight: 30,
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF7C9D96),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(
            'Setting',
            style: TextStyle(color: Color(0xFFF29545)),
          )
        ]),
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
          //日記の箱
          
        ],
      ),
    );
  }
}
