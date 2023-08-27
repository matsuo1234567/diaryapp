import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String title;

//イベント(日記)のタイトル(title)を格納するためのプロパティ
  const Event(this.title);

  @override
  String toString() => title;
}

//日付をキーとして、それに関するイベのリストを値とする連想配列(マップ)を定義
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  //日付のハッシュコードを計算するためにgetHashCodeを指定
  //ハッシュコードはデータ構造内で要素を格納・検索する際に使用する要素
  hashCode: getHashCode,
//まずLinkedHashMapを作成し、その後に_kEventSourceの内容を追加する
)..addAll(_kEventSource);

//List.generateで0~49までの数値を生成
final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
//イベントの日付を表すオブジェクト
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month),
//各日付に対するイベントをリスト化、item~1で1から4までのランダムなイベント数が生成
    value: (item) => List.generate(
//各イベントをテキスト形式で生成し、Event~1}という書式になっている
        item % 4 + 1,
        (index) => Event('Event $item | ${index + 1}')))
//カレンダーアプリ内の特定の日付に関する固定情報を示している
  ..addAll({
    DateTime(2023,8,26): [
      const Event(
          '今日は初めて日本に来ました。\n明日はマレーシアに行く予定です。\n明後日はロンドンに行きます。\n明明後日はブラジルに行きましょうか。'),
    ],

  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

//開始日と終了日を取り、範囲内の日付リストを返すdaysInRange関数を定義
List<DateTime> daysInRange(DateTime first, DateTime last) {
  //範囲間の日数を計算、+1は最初の日数を含むため
  final dayCount = last.difference(first).inDays + 1;
  //指定数(dayCount)の要素を持つリストを生成
  return List.generate(
    dayCount,
    //以下はList.generateのコールバック関数
    //
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now(); //今日の日付
final kFirstDay = DateTime(2022, 8, 28); //見れる最初の日付
final kLastDay = DateTime(2024, 8, 28);//見れる最後の日付
