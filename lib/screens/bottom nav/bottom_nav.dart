import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/screens/home.dart';
import 'package:talk_hub/screens/status_page.dart';

class BottomNavigationPage extends StatefulWidget {
  @override
  _BottomNavigationPageState createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
   const StatusPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: CupertinoColors.inactiveGray,
        selectedItemColor: const Color.fromARGB(255, 146, 255, 173),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Stories',
          ),
        ],
      ),
    );
  }
}
