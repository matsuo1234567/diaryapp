import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Align(
        alignment: Alignment.centerRight, // ここで右寄せに設定
        child: Text(
          "chat",
          style: TextStyle(color: Color(0xffE49B5B)),
        ),
      ),
      backgroundColor: Color(0xffF6F7F9),
    );
  }
}
