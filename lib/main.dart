import 'package:flutter/material.dart';
import 'pages/calendar/calendar.dart';
import 'pages/poll.dart';
import 'pages/smartwatch.dart';
import 'pages/profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: _MainPage(),
      initialRoute: '/',
      routes: {
        '/': (context) => _MainPage(),
        '/calendar': (context) => CalendarPage(),
        '/poll': (context) => PollPage(),
        '/smartwatch': (context) => SmartwatchPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

class _MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<_MainPage> {
  int _currentIndex = 3;
  final List<Widget> _tabs = [
    CalendarPage(),
    PollPage(),
    SmartwatchPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(34, 69, 151, 1),

        body: _tabs[_currentIndex],

        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_sharp),
            label: "Events",
            backgroundColor: Colors.black26,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.poll),
            label: "Poll",
            backgroundColor: Colors.black26,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch),
            label: "Smartwatch",
            backgroundColor: Colors.black26,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profile",
            backgroundColor: Colors.black26,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}