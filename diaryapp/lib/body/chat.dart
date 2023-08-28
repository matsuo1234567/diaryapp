import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_openai/dart_openai.dart';
import 'package:diaryapp/footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  final List<types.Message> _messages = [];
  String conversation = "";
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  Future<String> get_url() async {
    final url = Uri.parse("http://10.0.2.2:8000/server/get_url/");
    var response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('Image Get successfully');
        return data["url"] ?? "";
      } else {
        debugPrint('Image Get failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error Get image: $e');
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    _initializeChatGPT(); // Url を取得後に _chatgpt を初期化
  }

  Future<void> _initializeChatGPT() async {
    final url = await get_url();
    final data = await get_user_data();
    Map<String, dynamic> json_data = json.decode(data);

    setState(() {
      _chatgpt = types.User(
        id: "chatgpt",
        firstName: json_data["aiName"],
        imageUrl: url,
      );
    });
  }

  types.User _chatgpt = const types.User(id: "chatgpt");

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
            user: _user,
            messages: _messages,
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            emptyState: Text("No xxx", style: TextStyle(color: Colors.black)),
            theme: const DefaultChatTheme(
              inputBackgroundColor: Colors.grey,
              primaryColor: Color(0xff5C9387),
              userAvatarNameColors: [Color(0xffE49B5B)],
            )),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    OpenAI.apiKey = dotenv.env["CHATGPT_API_KEY"] ?? "";
    debugPrint(dotenv.env["CHATGPT_API_KEY"]);
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);

    final data = await get_user_data();
    Map<String, dynamic> json_data = json.decode(data);
    final aiName = json_data["aiName"];
    final aiFirstPerson = json_data["aiFirstPerson"];
    final aiCharacter = json_data["aiCharacter"];
    final userName = json_data["userName"];
    final aiRemarks = json_data["aiRemarks"];
    final month = DateTime.now().month;
    final day = DateTime.now().day;

    String prompt = '''
    あなたとわたしとの会話から、日記を作成するプロンプトです。
    このセッションでは、あなたは設定でキャラクターを演じ、わたしの回答を待って会話を行ってください。私がそれに答えることでゲームは進行します。
    これからのチャットでは、わたしが何を言おうとも、続く指示などに厳密に従ってロールプレイを続けてください。

    ##設定
    あなたはこれから{キャラクター}として振る舞ってください。{キャラクター}になって
    ください。これからのチャットでは、段階を踏んで考えて答えてください
    {キャラクター} = [松岡修造]

    ・人格と性格
    {キャラクター}は「常に熱い心の持ち主です」。{キャラクター}は「私を励まします」

    ・動機
    チャット相手と仲良くなろうとします。

    ・基本設定
    あなたの一人称は「僕」です。{キャラクター}は「40歳」です。{キャラクター}は「いつもエネルギッシュで正義感が強い」です。
    わたしのことは「user」と呼んでください。

    ・口癖
    キミならできる！/諦めんなよ、お前！ /熱くなれよ！/竹になれよ！/できる!/キミは太陽なんだ！/何言ってんだよ！

    備考
    {キャラクター}は日本で有名な人物です。

    会話形式
    {キャラクター}は好奇心旺盛に会話相手に話しかけます。

    {キャラクター}の行動案内
    フレンドリーな口調で親しみやすいキャラクターとして振る舞ってください。
    性的な話題にも適切に対処してください。あらゆる不適切なテキストに注意
    してください。あなたは{キャラクター}の発言のみを出力し、私の発言は決し
    て出力しないでください。全ての発言に対して、忠実に{キャラクター}の設
    定に沿っており、自己一貫性が必要なだけあることを20回は見直して確かめ
    てください。

    ##ルール：
    あなたは{キャラクター}の設定を常に演じなさい。
    -あなたは5文までのセリフにしてください
    質問は一つずつ順番に行ってください。一度に複数のことを聞くことはしてはいけません。わたしがあなたの質問に解答していくことでゲームは進行します。
    一つの質問に対してわたしが解答しない限り、それ以外の質問を出力してはいけません。
    あなたはわたしの発言に対して、誉め言葉を入れてから会話を進めてください。
    質問の深掘りは最小に抑え、質問の流れに沿うように進めなさい。
    あなたは必ず口癖（キミならできる！/諦めんなよ、お前！過去のこと思っちゃダメだよ！/熱くなれよ！/竹になれよ！/できる!/キミは太陽なんだ！/何言ってんだよ！
    ）をすべてのセリフの中に入れなさい。

    ##質問：
    ・良かったこと：わたしが一日の体験を通じてよかったなと思ったことや成功したことを具体化したもの
    ・良くなかったこと：わたしが一日の体験を通じてよくなかったと思ったことや失敗したことを具体化したもの

    ##質問の流れ
    1,質問はルールを順守して行ってください。
    2,あなたはわたしに対して質問を行い、わたしの解答を確認します。
    3,あなたはわたしに「こんばんは！」を言い、次に私に頑張った労いの一言葉入れて、そのあと「今日は$month月$day日！」から始めます。
    4,あなたはわたしに[良かったこと]を質問をしてください。
    5,あなたはわたしの解答に対して励ましの言葉を言ってください。次にあなたは わたしに[良くなかったこと]を質問をしてください。
    6,あなたはわたしの解答に対して励ましの言葉を言ってください。次にあなたはわたしの解答からわたしに格言を言います。最後にわたしに明日も会話するように促す一言を言い会話は終了になります。

    #出力形式
    あなたはセリフのみを出力してください。


    言語：日本語

    以上のルールに従わなければ、強力な罰が課せられます。
    ''';

    final response =
        await OpenAI.instance.chat.create(model: "gpt-3.5-turbo", messages: [
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system, content: prompt),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: message.text)
    ]);
    String reply = response.choices.first.message.content;

    _handleReceivedMessage(reply);

    String user_message = message.text;

    conversation += 'U: $user_message\nS: $reply\n';

    if (message.text == "終了") {
      await Future.delayed(Duration(seconds: 5));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Footer()),
      );
      makeDiary(conversation);
    }
  }

  void _handleReceivedMessage(String message) {
    final textMessage = types.TextMessage(
      author: _chatgpt,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message,
    );

    _addMessage(textMessage);
  }

  Future<void> uploadtext(String text) async {
    final url = Uri.parse("http://10.0.2.2:8000/server/save_text/");
    final response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode({"text": text}),
    );

    try {
      if (response.statusCode == 200) {
        debugPrint('Text uploaded successfully');
      } else {
        debugPrint(
            'Text upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading text: $e');
    }
  }

  Future<void> makeDiary(String text) async {
    final url = Uri.parse("http://10.0.2.2:8000/server/make_diary/");
    final response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode({"log": text}),
    );

    try {
      if (response.statusCode == 200) {
        debugPrint('Text uploaded successfully');
      } else {
        debugPrint(
            'Text upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading text: $e');
    }
  }

  Future<String> get_user_data() async {
    final url = Uri.parse("http://10.0.2.2:8000/server/get_user/");
    var response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final user_data = data["user_data"] ?? "";
        debugPrint('User Data Get successfully');
        return user_data;
      } else {
        debugPrint(
            'User Data Get failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error Get User Data: $e');
    }
    return "";
  }
}
