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
    Map<DateTime, List<int>> hrs = {};
    Map<DateTime, Map<int, List<int>>> hourly_hrs = {};

    heart_firestoreData.forEach((i) {
      DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
      DateTime date = new DateTime(d.year, d.month, d.day);

      // features
      List<int> list = hrs[date] ?? [];
      list.add(i.bpm);
      hrs[date] = list;

      // hourly heart rate
      int hour = d.hour;
      Map<int, List<int>> map = hourly_hrs[date] ?? {};
      List<int> list2 = map[hour] ?? [];
      list2.add(i.bpm);
      map[hour] = list2;
      hourly_hrs[date] = map;
    });

    // features
    hrs.forEach((date, list) async {
      int avg_hr = list.reduce((a,b)=>a+b).toDouble() ~/ list.length;
      int max_hr = list.reduce(max);
      int min_hr = list.reduce(min);

      await FirestoreService(uid: "${user.email}").heartFeatures(date, avg_hr, max_hr, min_hr);
    });

    // hourly heart rate
    hourly_hrs.forEach((date, map) async {
      Map<String, int> res_map = {};
      map.forEach((hour, list) {
        String time = "$hour:00".padLeft(5, '0');
        int added = list.reduce((a,b)=>a+b).toDouble() ~/ list.length;
        res_map[time] = added;
      });

      await FirestoreService(uid: "${user.email}").hourlyHeartRate(date, res_map);
    });
    // endregion


    // region STEP
    Map<DateTime, List<int>> features_step = {};   // 0=steps, 1=distance
    Map<DateTime, Map<int, int>> hourly_steps = {};

    // distance
    distance_firestoreData.forEach((i) {
      DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
      DateTime date = new DateTime(d.year, d.month, d.day);

      List<int> dist_sum = features_step[date] ?? [0,0];
      dist_sum[1] = dist_sum[1] + i.distance;
      features_step[date] = dist_sum;
    });

    // steps
    steps_firestoreData.forEach((i) {
      DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
      DateTime date = new DateTime(d.year, d.month, d.day);

      // features
      List<int> steps_sum = features_step[date] ?? [0,0];
      steps_sum[0] = steps_sum[0] + i.steps;
      features_step[date] = steps_sum;

      // hourly steps
      int total = 0;
      int hour = d.hour;

      Map<int, int> map = hourly_steps[date] ?? {};
      map[hour] = (map[hour] ?? total) + i.steps;
      hourly_steps[date] = map;
      total += i.steps;
    });

    // features
    features_step.forEach((date, tuple) async {
      int steps = tuple[0];
      int distance = tuple[1];
      if (steps != 0) await FirestoreService(uid: "${user.email}").stepFeatures(date, steps, distance);
    });

    // hourly steps
    hourly_steps.forEach((date, map) async {
      Map<String, int> res_map = {};
      int total = 0;

      map.forEach((hour, sum) {
        String time = "$hour:00".padLeft(5, '0');
        total += sum;
        res_map[time] = total;
      });

      await FirestoreService(uid: "${user.email}").hourlySteps(date, res_map);
    });
    // endregion


    // region ACTIVITY
    Map<DateTime, List<int>> features_activity = {};   // 0=calories, 1=move mins
    Map<DateTime, Map<int, int>> hourly_calories = {};

    // movement minutes
    movemins_firestoreData.forEach((i) {
      DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
      DateTime date = new DateTime(d.year, d.month, d.day);

      List<int> tuple = features_activity[date] ?? [0,0];
      tuple[1] = tuple[1] + i.move_minutes;
      features_activity[date] = tuple;
    });

    // calories
    activity_firestoreData.forEach((i) {
      DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
      DateTime date = new DateTime(d.year, d.month, d.day);

      // features
      List<int> tuple = features_activity[date] ?? [0,0];
      tuple[0] = tuple[0] + i.burned;
      features_activity[date] = tuple;

      // hourly calories
      int total = 0;
      int hour = d.hour;

      Map<int, int> map = hourly_calories[date] ?? {};
      map[hour] = (map[hour] ?? total) + i.burned;
      hourly_calories[date] = map;
      total += i.burned;
    });

    // features
    features_activity.forEach((date, tuple) async {
      int calories = tuple[0];
      int move_mins = tuple[1];
      if (calories != 0) await FirestoreService(uid: "${user.email}").activityFeatures(date, calories, move_mins);
    });

    // hourly calories
    hourly_calories.forEach((date, map) async {
      Map<String, int> res_map = {};
      int total = 0;

      map.forEach((hour, sum) {
        String time = "$hour:00".padLeft(5, '0');
        total += sum;
        res_map[time] = total;
      });

      await FirestoreService(uid: "${user.email}").hourlyCalories(date, res_map);
    });
    // endregion


    // region SLEEP
    Map<DateTime, Map<String, int>> features_sleep = {};
    Map<DateTime, List<String>> allIntervals = {};

    sleep_firestoreData.forEach((i) {
      DateTime s = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
      DateTime e = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.endtime.substring(0, i.endtime.length - 6)));
      DateTime date = new DateTime(s.year, s.month, s.day);

      int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
      int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
      int mins = (end/60000).floor() - (start/60000).floor();

      Map<String, int> map = features_sleep[date] ?? {};
      if (i.type == "awake") {          // awake
        int awake = map["awake"] ?? 0;
        awake += mins;
        map["awake"] = awake;
      }
      if (i.type == "light sleep") {    // light sleep
        int light = map["light"] ?? 0;
        light += mins;
        map["light"] = light;
      }
      if (i.type == "deep sleep") {     // deep sleep
        int deep = map["deep"] ?? 0;
        deep += mins;
        map["deep"] = deep;
      }
      if (i.type == "rem sleep") {      // rem sleep
        int rem = map["rem"] ?? 0;
        rem += mins;
        map["rem"] = rem;
      }
      features_sleep[date] = map;

      List<String> ranges = allIntervals[date] ?? [];
      String start_time = "${s.hour.toString().padLeft(2,'0')}:${s.minute.toString().padLeft(2,'0')}";
      String end_time = "${e.hour.toString().padLeft(2,'0')}:${e.minute.toString().padLeft(2,'0')}";
      String format = "${i.type}~$start_time to $end_time";
      ranges.add(format);
      allIntervals[date] = ranges;
    });

    // features
    features_sleep.forEach((date, map) async {
      int a = map["awake"] ?? 0;
      int l = map["light"] ?? 0;
      int d = map["deep"] ?? 0;
      int r = map["rem"] ?? 0;

      String awake = "${(a / 60).floor()}h ${(a % 60)}m";
      String light = "${(l / 60).floor()}h ${(l % 60)}m";
      String deep = "${(d / 60).floor()}h ${(d % 60)}m";
      String rem = "${(r / 60).floor()}h ${(r % 60)}m";

      String start_time = allIntervals[date][0].split("~")[1].split(" to ")[0];
      String end_time = allIntervals[date].last.split(" to ")[1];

      await FirestoreService(uid: "${user.email}").sleepFeatures(date, awake, light, deep, rem, start_time, end_time);
    });

    // sleep tracker
    allIntervals.forEach((date, list) async {
      Map<String, String> times = {};
      int ct = 1;

      list.forEach((i) {
        String type = "${ct.toString().padLeft(2,'0')} - ${i.split("~")[0]}";
        String interval = i.split("~")[1];
        ct += 1;

        times[type] = interval;
      });

      await FirestoreService(uid: "${user.email}").sleepTracker(date, times);
    });
    //endregion
  }


  @override
  void initState() {
    if (!smartwatchUploaded) {
      smartwatchUploaded = true;
      updateFirestore();
    }

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
          actions: [
            IconButton(
              splashRadius: 20,
              icon: Icon(Icons.refresh, size: 30,),
              onPressed: () async {
                // // refresh date (if midnight passed)
                // DateTime d = DateTime.now();
                // day = DateTime(d.year, d.month, d.day);

                await Navigator.pushNamed(context, '/api');
                updateFirestore();
              },
            )
          ],

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
        //
        //   },
        //   child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
        // ),


      ),
    );
  }
}
