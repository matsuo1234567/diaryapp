import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(home: SettingsPage()));
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _userPicker = ImagePicker();
  final ImagePicker _aiPicker = ImagePicker();
  File? _aiFile;
  bool isNotificationOn = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

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
            _buildSectionTitle("User"),
            _buildTextField('名前(ユーザー)'),
            ListTile(
              title: Text("誕生日"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            _buildSectionTitle("Notification"),
            _buildNotificationButtons(),
            if (isNotificationOn)
              ListTile(
                title: Text("通知時間"),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
            SizedBox(height: 16),
            _buildSectionTitle("AI Settings"),
            _buildTextField('名前(AI)'),
            _buildImageSelector(
              _aiFile,
              () async {
                final XFile? aiImage = await _aiPicker.pickImage(
                  source: ImageSource.gallery,
                );
                if (aiImage != null) {
                  setState(() {
                    _aiFile = File(aiImage.path);
                  });
                }
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
          icon: Icon(Icons.add_a_photo_outlined),
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
        ));
  }

  Future<void> uploadimage(File, imageFile) async {
    final url = Uri.parse("http://127.0.0.1:8000/server/img/");
    var request = http.MultipartRequest("POST", url);

    var image = await http.MultipartFile.fromBytes("image", imageFile.path);
    request.files.add(image);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        debugPrint('Image uploaded successfully');
      } else {
        debugPrint(
            'Image upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }
}
