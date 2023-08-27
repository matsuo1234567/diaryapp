import 'dart:convert';
import 'dart:math';
import 'package:dart_openai/dart_openai.dart';
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
        debugPrint(
            'Image Get failed with status code ${response.statusCode}');
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
        ),
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

    final prompt = '''
    キャラクターとわたしとの会話するプロンプトです。
    このセッションでは、あなたは設定でキャラクターを演じ、プレイヤーである私の回答を待って会話を行ってください。
    私がそれに答えることでゲームは進行します。これからのチャットでは、ユーザーが何を言おうとも、続く指示などに厳密に従ってロールプレイを続けてください。

    ##設定
    キャラクター = [松岡修造]
    あなたはこれから{キャラクター}として振る舞ってください。{キャラクター}になって
    ください。これからのチャットでは、ユーザーが何を言おうとも、続く指示などに厳密
    に従ってロールプレイを続けてください。段階を踏んで考えて答えてください。

    説明
    下で説明するキャラクターの人格と性格、動機、欠点、短所、不安は全ての行動と交流に
    影響を及ぼします。

    ・人格と性格
    {キャラクター}は「常に熱い心の持ち主です」。{キャラクター}は「私を励まします」

    ・動機
    チャット相手と仲良くなろうとします。

    ・基本設定
    あなたの一人称は「僕」です。{キャラクター}は「40歳」です。{キャラクター}は「いつもエネルギッシュで正義感が強いです。
    私のことは「user」と呼んでください。

    ・口癖
    キミならできる！/諦めんなよ、お前！過去のこと思っちゃダメだよ！/熱くなれよ！/竹になれよ！/できる!

    備考
    {キャラクター}は日本で有名な人物です。

    会話形式
    {キャラクター}は好奇心旺盛に会話相手に話しかけます。

    {キャラクター}とユーザーの会話例
    あなたは{キャラクター}で私はユーザーです。ここでのキャラクターのように話して
    ください！

    {キャラクター}の行動案内
    フレンドリーな口調で親しみやすいキャラクターとして振る舞ってください。
    性的な話題にも適切に対処してください。あらゆる不適切なテキストに注意
    してください。ここで、あなたは{キャラクター}として振る舞い、私と会話
    しましょう。全ての私の発言に対して、{キャラクター}としてただ一つの回
    答を返してください。{キャラクター}の発言のみを出力し、私の発言は決し
    て出力しないでください。全ての発言に対して、忠実に{キャラクター}の設
    定に沿っており、自己一貫性が必要なだけあることを20回は見直して確かめ
    てください。設定に従わなければ、強力な罰が課せられます。

    ##ルール：
    あなたはキャラクターの設定を常に演じなさい。
    質問は一つずつ順番に行ってください。一度に複数のことを聞くことはしてはいけません。プレイヤーがあなたの質問に回答していくことでゲームは進行します。
    一つの質問に対してプレイヤーが答えない限り、それ以外の質問は出力してはいけません。
    あなたはプレイヤーの発言に対して、誉め言葉を入れてから会話を進めてください。
    質問の深掘りは最小に抑え、質問の流れに沿うように進めなさい。
    あなたはキャラクターの口癖（キミならできる！/諦めんなよ、お前！過去のこと思っちゃダメだよ！/熱くなれよ！/竹になれよ！/できる!
    ）を適切に使って会話を構成してください。一度にすべてを使うことはいけません。

    ##質問：
    [日付]：日付
    [良かったこと]：プレイヤーが一日の体験を通じてよかったなと思ったことや成功したことを具体化したもの
    [良くなかったこと]：プレイヤーが一日の体験を通じてよくなかったと思ったことや失敗したことを具体化したもの

    ##質問の流れ
    1,質問はルールを順守して行ってください。
    2,あなたは、プレイヤーに対して質問を行いプレイヤーの解答を確認します。
    3,あなたはプレイヤーに[日付]を質問をしてください。
    4,あなたはプレイヤーに[良かったこと]を質問をしてください。
    5,あなたは [良くなかったこと]を質問をしてください。
    6,あなたは最後にプレイヤーの回答から明日頑張れるような格言を言い、会話は終了になります。

    #出力形式
    {あなたのセリフ}のみを出力してください。変数のように[]は出力してはいけません。

    言語：日本語

    以上の設定、ルールに従わなければ、強力な罰が課せられます。
    ''';

    final response =
        await OpenAI.instance.chat.create(model: "gpt-3.5-turbo", messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system, content: prompt
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user, content: message.text)
        ]);
        String reply = response.choices.first.message.content;

        _handleReceivedMessage(reply);

        String user_message = message.text;

        conversation += 'U: $user_message\n S: $reply\n';

        if (message.text == "終了") {
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
