import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MaterialApp(home: SettingsPage()));
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _userPicker = ImagePicker();
  final ImagePicker _aiPicker = ImagePicker();
  File? _userFile;
  File? _aiFile;
  bool isNotificationOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F7F9),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xff5C9387)),
        elevation: 0,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            "settings",
            style: TextStyle(color: Color(0xffE49B5B)),
          ),
        ),
        backgroundColor: Color(0xffF6F7F9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // User

            _buildSectionTitle("User"),
            _buildTextField('名前(ユーザー)'),

            _buildTextField('誕生日'),
            SizedBox(height: 16),

            // Notification
            _buildSectionTitle("Notification"),
            _buildNotificationButtons(),

            // Time Picker
            if (isNotificationOn) _buildTextField('通知時間'),
            SizedBox(height: 16),

            // AI Settings
            _buildSectionTitle("AI Settings"),
            _buildTextField('名前(AI)'),
            _buildImageSelector(
              _aiFile,
              () async {
                final XFile? aiImage = await _aiPicker.pickImage(
                  source: ImageSource.gallery,
                );
                _aiFile = File(aiImage!.path);
                setState(() {});
              },
            ),
            _buildTextField('一人称'),
            _buildTextField('性格'),
            _buildTextField('短所'),
            _buildTextField('好きなもの'),
            _buildTextField('嫌いなもの'),
            _buildTextField('備考', maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: Color(0xff5C9387),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff5C9387),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff5C9387),
          ),
        ),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildImageSelector(File? file, VoidCallback onPressed) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: onPressed,
        ),
        SizedBox(width: 16),
        file != null
            ? Image.file(
                file,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Container(
                width: 50,
                height: 50,
                color: Colors.grey,
              ),
      ],
    );
  }

  Widget _buildNotificationButtons() {
    return Row(
      children: [
        _buildNotificationButton('ON', true),
        SizedBox(width: 16),
        _buildNotificationButton('OFF', false),
      ],
    );
  }

  Widget _buildNotificationButton(String label, bool value) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isNotificationOn = value;
        });
      },
      child: Text(label),
      style: ElevatedButton.styleFrom(
        primary: isNotificationOn == value ? Color(0xffE49B5B) : Colors.grey,
        elevation: isNotificationOn == value ? 2 : 0,
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      ),
    )
    );
  }
}
