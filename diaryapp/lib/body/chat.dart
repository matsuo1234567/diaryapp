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
  String Url = "";
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  Future<void> get_url() async {
    final url = Uri.parse("http://127.0.0.1:8000/server/get_url/");
    var response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        Url = data["url"];
        debugPrint('Image uploaded successfully');
      } else {
        debugPrint(
            'Image upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeChatGPT(); // Url を取得後に _chatgpt を初期化
  }

  Future<void> _initializeChatGPT() async {
    await get_url(); // Url を取得

    setState(() {
      _chatgpt = types.User(
        id: "chatgpt",
        firstName: "Ikeuchi",
        lastName: "Akira",
        imageUrl: Url,
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
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);

    final response =
        await OpenAI.instance.chat.create(model: "gpt-3.5-turbo", messages: [
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: message.text)
    ]);
    String reply = response.choices.first.message.content;

    _handleReceivedMessage(reply);

    String user_message = message.text;

    conversation += 'U: $user_message\n S: $reply\n';

    if (message.text == "終了") {
      final diary =
          await OpenAI.instance.chat.create(model: "gpt-3.5-turbo", messages: [
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user, content: conversation)
      ]);
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
}
