import 'package:flutter/material.dart';
import 'package:fit_kit/fit_kit.dart';
import 'dart:async';

class SmartwatchPage extends StatefulWidget {
  @override
  _SmartwatchPageState createState() => _SmartwatchPageState();
}

class _SmartwatchPageState extends State<SmartwatchPage> {

  Widget button(String _text, IconData _icon, String _route, double LR) {
    double multiplier = 1.5;
    return GestureDetector(
      child: Card(
        // color: Colors.black54,
        color: Colors.grey[200],
        child: Padding(
          padding: EdgeInsets.fromLTRB(LR*multiplier, 16*multiplier, LR*multiplier, 16*multiplier),
          // padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(
                _icon,
                color: Colors.blueAccent,
                size: 40,
              ),
              SizedBox(height: 2,),
              Text(
                _text,
                style: TextStyle(
                  fontSize: 23,
                  fontFamily: 'mont',
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        print("$_text");
        Navigator.pushNamed(context, _route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromRGBO(34, 69, 151, 1),

        appBar: AppBar(
          title: Text('Behaviorome', style: TextStyle(fontFamily: 'mont-med'),),
          centerTitle: true,
          backgroundColor: Colors.black12,
          elevation: 5,
        ),

        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.0),
              Icon(
                Icons.watch,
                color: Colors.white,
                size: 100,
              ),

              SizedBox(height: 100.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button("Step", Icons.directions_run, "/step", 24),
                  SizedBox(width: 20,),
                  button("Activity", Icons.directions_bike, "/activity", 13),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button("Sleep", Icons.bed, "/sleep", 20),
                  SizedBox(width: 20,),
                  button("Heart", Icons.favorite, "/heart", 21),
                ],
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            Navigator.pushNamed(context, "/test");
          },
          child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
        ),

      ),
    );
  }
}
