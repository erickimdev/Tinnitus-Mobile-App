import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'data.dart';
import '../../main.dart';
import '../../services/firestore.dart';

class SmartwatchPage extends StatefulWidget {
  @override
  _SmartwatchPageState createState() => _SmartwatchPageState();
}

int uploadPercent = 0;
bool uploading = false;
class _SmartwatchPageState extends State<SmartwatchPage> {
  Widget button(String _text, IconData _icon, String _route, double LR) {
    double multiplier = 1.5;
    return GestureDetector(
      child: Card(
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
        Navigator.pushNamed(context, _route);
      },
    );
  }

  void updateFirestore() async {
    // region HEART
    int avg_hr = heart_day_heartrate.reduce((a,b)=>a+b).toDouble() ~/ heart_day_heartrate.length;
    int max_hr = heart_day_heartrate.reduce(max);
    int min_hr = heart_day_heartrate.reduce(min);
    await FirestoreService(uid: "${user.email}").heartFeatures(day, avg_hr, max_hr, min_hr);
    await FirestoreService(uid: "${user.email}").hourlyHeartRate(day, firestore_hr);
    // endregion


    // region STEP
    await FirestoreService(uid: "${user.email}").stepFeatures(day, steps_day_steps, steps_day_distance);
    await FirestoreService(uid: "${user.email}").hourlySteps(day, firestore_steps);
    // endregion


    // region ACTIVITY
    await FirestoreService(uid: "${user.email}").activityFeatures(day, activity_day_calories, activity_day_movemins);
    await FirestoreService(uid: "${user.email}").hourlyCalories(day, firestore_calories);
    // endregion


    // region SLEEP
      // features
      String awake = "${(sleep_day_awake / 60).floor()}h ${(sleep_day_awake % 60)}m";
      String light = "${(sleep_day_light / 60).floor()}h ${(sleep_day_light % 60)}m";
      String deep = "${(sleep_day_deep / 60).floor()}h ${(sleep_day_deep % 60)}m";
      String rem = "${(sleep_day_rem / 60).floor()}h ${(sleep_day_rem % 60)}m";

      int s = int.parse(sleep_allDayData[0].starttime.substring(0, sleep_allDayData[0].starttime.length - 6));
      DateTime start = new DateTime.fromMillisecondsSinceEpoch(s);
      String start_time = "${start.hour}:${start.minute}".padLeft(5, '0');

      int e = int.parse(sleep_allDayData.last.endtime.substring(0, sleep_allDayData.last.endtime.length - 6));
      DateTime end = new DateTime.fromMillisecondsSinceEpoch(e);
      String end_time = "${end.hour}:${end.minute}".padLeft(5, '0');

      await FirestoreService(uid: "${user.email}").sleepFeatures(day, awake, light, deep, rem, start_time, end_time);


      // sleep tracker
      Map<String, String> tracker = new Map();
      int count = 0;

      sleep_allDayData.forEach((i) {
        int s = int.parse(i.starttime.substring(0, i.starttime.length - 6));
        DateTime start = new DateTime.fromMillisecondsSinceEpoch(s);
        String start_time = "${start.hour}:${start.minute}".padLeft(5, '0');

        int e = int.parse(i.endtime.substring(0, i.endtime.length - 6));
        DateTime end = new DateTime.fromMillisecondsSinceEpoch(e);
        String end_time = "${end.hour}:${end.minute}".padLeft(5, '0');

        count += 1;

        tracker["${count.toString().padLeft(2, '0')} - ${i.type}"] = "$start_time to $end_time";
      });

      await FirestoreService(uid: "${user.email}").sleepTracker(day, tracker);
    //endregion
  }

  @override
  void initState() {
    updateFirestore();

    super.initState();
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
              // big watch icon
              SizedBox(height: 50.0),
              Icon(
                Icons.watch,
                color: Colors.white,
                size: 100,
              ),

              // "Choose a metric."
              SizedBox(height: 60.0),
              Text(
                "Choose a metric.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: "mont-med",
                ),
              ),

              // 4 buttons
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button("Step", Icons.directions_run, "/step", 24),
                  SizedBox(width: 20,),
                  button("Activity", Icons.directions_bike, "/activity", 13),
                ],
              ),
              SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button("Sleep", Icons.bedtime_rounded, "/sleep", 20.5),
                  SizedBox(width: 20,),
                  button("Heart", Icons.favorite, "/heart", 20),
                ],
              ),

              SizedBox(height: 40.0),
            ],
          ),
        ),

        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.red,
        //   onPressed: () {
        //     Navigator.pushNamed(context, "/test");
        //   },
        //   child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
        // ),

      ),
    );
  }
}
