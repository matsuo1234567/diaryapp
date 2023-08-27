import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: SettingsPage()));
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userBirthdayController = TextEditingController();
  TextEditingController notificationTimeController = TextEditingController();
  TextEditingController aiNameController = TextEditingController();
  TextEditingController aiFirstPersonController = TextEditingController();
  TextEditingController aiCharacterController = TextEditingController();
  TextEditingController aiConsController = TextEditingController();
  TextEditingController aiLikeController = TextEditingController();
  TextEditingController aiDislikeController = TextEditingController();
  TextEditingController aiRemarksController = TextEditingController();

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
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      userBirthdayController.text =
          selectedDate.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
      notificationTimeController.text = selectedTime.format(context);
    }
  }

  Future<void> _saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/ai_image.png';

    await image.copy(imagePath);

    setState(() {
      _aiFile = File(imagePath);
    });
  }

  Future<void> uploadUserData(String data) async {
    final url = Uri.parse("http://10.0.2.2:8000/server/save_user/");
    final response = await http.post(
      url,
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode({"data": data}),
    );

    try {
      if (response.statusCode == 200) {
        debugPrint('User data uploaded successfully');
      } else {
        debugPrint(
            'User data upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading User data: $e');
    }
  }

  Future<void> get_user_data() async {
    final url = Uri.parse("http://10.0.2.2:8000/server/get_user/");
    var response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final user_data = data["user_data"];
        debugPrint('User Data Get successfully');
        return user_data;
      } else {
        debugPrint(
            'User Data Get failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error Get User Data: $e');
    }
  }

  Future<void> get_url() async {
    final url = Uri.parse("http://10.0.2.2:8000/server/get_url/");
    var response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data["url"];
        debugPrint('Image uploaded successfully');
      } else {
        debugPrint(
            'Image upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  Future<void> uploadSettings() async {
    // Collect values from controllers
    var settings = {
      'userName': userNameController.text,
      'userBirthday': userBirthdayController.text,
      'notificationTime': notificationTimeController.text,
      'aiName': aiNameController.text,
      'aiFirstPerson': aiFirstPersonController.text,
      'aiCharacter': aiCharacterController.text,
      'aiCons': aiConsController.text,
      'aiLike': aiLikeController.text,
      'aiDislike': aiDislikeController.text,
      'aiRemarks': aiRemarksController.text,
      'isNotificationOn': isNotificationOn,
    };
    //debug
    print("Collected settings: $settings");

    var settingsJson = jsonEncode(settings);
    //debug
    print("JSON representation: $settingsJson");

    uploadUserData(settingsJson);
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
            _buildTextField('あなたの名前', userNameController),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField('誕生日', userBirthdayController),
              ),
            ),
            SizedBox(height: 16),
            _buildSectionTitle("Notification"),
            _buildNotificationButtons(),
            if (isNotificationOn)
              GestureDetector(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: _buildTextField('通知時間', notificationTimeController),
                ),
              ),
            SizedBox(height: 16),
            _buildSectionTitle("AI Settings"),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('AIの名前', aiNameController),
                ),
                _buildImageSelector(
                  _aiFile,
                  () async {
                    var camerastatus = await Permission.camera.status;
                    var photosstatus = await Permission.photos.status;
                    var mediaLibrarystatus =
                        await Permission.mediaLibrary.status;

                    if (camerastatus.isDenied ||
                        photosstatus.isDenied ||
                        mediaLibrarystatus.isDenied) {
                      await Permission.camera.request();
                      await Permission.photos.request();
                      await Permission.mediaLibrary.request();
                    }
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
              ],
            ),
            _buildTextField('一人称', aiFirstPersonController),
            _buildTextField('性格', aiCharacterController),
            _buildTextField('短所', aiConsController),
            _buildTextField('好きなもの', aiLikeController),
            _buildTextField('嫌いなもの', aiDislikeController),
            _buildTextField('備考', aiRemarksController, maxLines: 3),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await uploadSettings();
                await uploadimage(_aiFile!);
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xffE49B5B),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
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

  Widget _buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
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
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: file != null
            ? null
            : Icon(
                Icons.person,
                color: Colors.white,
                size: 30.0,
              ),
        backgroundImage: file != null ? FileImage(file) : null,
      ),
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

  Future<void> uploadimage(File imageFile) async {
    final url = Uri.parse("http://10.0.2.2:8000/server/img/");
    var request = http.MultipartRequest("POST", url);

    var image = await http.MultipartFile.fromPath("image", imageFile.path);
    request.files.add(image);

    try {
      final response = await request.send();
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
