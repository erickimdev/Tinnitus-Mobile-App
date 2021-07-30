import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tinnitus_app/main.dart';
import 'calendar/utils.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String LR_appbar = "Register";
  String LR_button = "Login";
  String _email = '';
  String _password = '';

  Widget _body() {
    if (loggedIn) {
      setState(() {
        LR_appbar = "Logout";
      });
      return Column(
        children: <Widget>[
          SizedBox(height: 70.0),
          Text("You are logged in\n${user.email}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ],
      );
    }
    else {
      return Column(
        children: [
          // EMAIL ADDRESS FORM
          Container(
            width: 350,
            child: TextFormField(
              textAlign: TextAlign.center,
              onChanged: (i) {
                setState(() => _email = i);
              },
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                fillColor: Colors.white70,
                enabledBorder:OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400], width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),

          // PASSWORD FORM
          SizedBox(height: 10.0),
          Container(
            width: 350,
            child: TextFormField(
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (i) {
                setState(() => _password = i);
              },
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                fillColor: Colors.white70,
                enabledBorder:OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400], width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),

          // LOGIN/REGISTER BUTTON
          SizedBox(height: 30.0),
          TextButton.icon(
            onPressed: () async {
              if (LR_button == "Register") {
                // register
                user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password)).user;
              }
              else if (LR_button == "Login") {
                // login
                user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password)).user;
              }

              if (user != null) {
                setState(() {
                  LR_appbar = "Logout";
                  loggedIn = true;
                });
              }
            },
            icon: Icon(
              Icons.check,
              color: Colors.white70,
              size: 30,
            ),
            label: Text(
              LR_button,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 21,
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();

    if (user != null) LR_appbar = "Logout";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Profile Page'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
        // appbar register/login button
        actions: [
          TextButton(
            onPressed: () async {
              setState(() {
                if (LR_appbar == "Register") {
                  LR_appbar = "Login";
                  LR_button = "Register";
                }
                else if (LR_appbar == "Login") {
                  LR_appbar = "Register";
                  LR_button = "Login";
                }
              });
              if (LR_appbar == "Logout") {
                await FirebaseAuth.instance.signOut();
                setState(() {
                  LR_appbar = "Register";
                  user = null;
                  loggedIn = false;
                  dailySubmitted = false;
                  calendarSynced = false;
                  kEvents.clear();
                });
              }
            },
            child: Text(
              LR_appbar,
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            )
          ),
        ],
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            // PROFILE ICON
            SizedBox(height: 30.0),
            Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 15.0),
            Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 70.0),
            _body(),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   onPressed: () {
      //     print("email: $_email");
      //     print("password: $_password");
      //     print("user: $user");
      //   },
      //   child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
      // ),

    );
  }
}