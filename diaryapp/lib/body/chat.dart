import 'dart:convert';
import 'dart:math';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  final _chatgpt = const types.User(
      id: "chatgpt",
      firstName: "Ikeuchi",
      lastName: "Akira",
      imageUrl: "http://10.0.2.2:8000/server/img/Akira_0809_IDhkeR8.jpg");

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
