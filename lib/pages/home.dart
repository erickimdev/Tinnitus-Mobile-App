import 'package:flutter/material.dart';
import 'package:tinnitus_app/main.dart';

import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget button(IconData _icon, String _text, String _route) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(67, 23, 0, 0),
      child: Row(
        children: [
          Icon(
            _icon,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(width: 5),
          TextButton(
            onPressed: () {
              if (!loggedIn) {      // enable for proper login use
              // if (loggedIn) {    // enable for convenient smartwatch
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You must be logged in"),
                    duration: Duration(milliseconds: 1000),
                  ),
                );
              }
              else Navigator.pushNamed(context, _route);
            },
            child: Text(
              _text,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'mont-med',
              ),
            ),

          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
        actions: [
          IconButton(
            splashRadius: 20,
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Icon(
              Icons.account_circle,
              size: 30,
            ),
          )
        ],
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            // HOME PAGE ICON
            SizedBox(height: 30.0),
            Icon(
              Icons.house,
              color: Colors.white,
              size: 100,
            ),

            SizedBox(height: 70.0),
            Divider(
              color: Colors.white,
              thickness: 0.4,
              height: 0,
              indent: 50,
              endIndent: 50,
            ),

            // CALENDAR BUTTON
            SizedBox(height: 20.0),
            button(Icons.calendar_today_sharp, 'Tinnitus Events Calendar', '/calendar'),

            // MYFEELINGS BUTTON
            SizedBox(height: 20.0),
            button(Icons.poll, 'Daily Feelings', '/poll'),

            // SMARTWATCH BUTTON
            SizedBox(height: 20.0),
            button(Icons.watch, 'My Smartwatch Data', '/smartwatch'),

            SizedBox(height: 40.0),
            Divider(
              color: Colors.white,
              thickness: 0.4,
              height: 0,
              indent: 50,
              endIndent: 50,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: Text("LOGIN"),
        onPressed: () async {
          user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: "eric@gmail.com", password: "asdfgh")).user;
          loggedIn = true;
          print("logged in");
        },
      ),

    );
  }
}