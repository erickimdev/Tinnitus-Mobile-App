import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/calendar/calendar.dart';
import 'pages/poll/poll.dart';
import 'pages/smartwatch/smartwatch.dart';
import 'pages/profile.dart';
import 'pages/calendar/addEvent.dart';
import 'pages/smartwatch/parts/step.dart';
import 'pages/smartwatch/parts/activity.dart';
import 'pages/smartwatch/parts/sleep.dart';
import 'pages/smartwatch/parts/heart.dart';
import 'pages/smartwatch/parts/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

User user;
bool loggedIn = false;
bool dailySubmitted = false;
bool calendarSynced = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),

        '/calendar': (context) => CalendarPage(),
        '/add_event': (context) => AddEvent(),

        '/poll': (context) => PollPage(),

        '/smartwatch': (context) => SmartwatchPage(),
        '/step': (context) => StepsPage(),
        '/activity': (context) => ActivityPage(),
        '/sleep': (context) => SleepPage(),
        '/heart': (context) => HeartPage(),
        '/test': (context) => TestPage(),
      },
      theme: ThemeData(
        fontFamily: 'mont-med',
      ),
    );
  }
}

class _MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<_MainPage> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    HomePage(),
    CalendarPage(),
    PollPage(),
    SmartwatchPage(),
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
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.black26,
          ),
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
        ],
        onTap: (index) {
          setState(() {
            if (!loggedIn && (index == 1 || index == 2 || index == 3)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You must be logged in"),
                  duration: Duration(milliseconds: 1000),
                ),
              );
            }
            else _currentIndex = index;
          });
        },
      ),
    );
  }
}

class Login {
  bool loggedIn;

  Login(this.loggedIn);
}