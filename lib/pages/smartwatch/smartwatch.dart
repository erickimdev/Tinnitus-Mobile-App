import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tinnitus_app/main.dart';
import 'package:health/health.dart';
import 'parts/utils.dart';

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
  void askPermissions() async { activityPermission = await Permission.activityRecognition.request(); }

  int uploadPercent = 0;
  bool uploading = false;
  Widget uploadButton() {
    if (!uploading) {
      return TextButton.icon(
        icon: Icon(Icons.upload),
        label: Text("Upload Month's Data", style: TextStyle(fontSize: 17),),
        onPressed: () async {
          bool confirm = await confirmUpload();
          if (confirm) {
            setState(() { uploading = true; });
            bool healthPermissionsGranted = await health.requestAuthorization(types);
            if (healthPermissionsGranted) await gatherMonthData();
          }
        }
      );
    }
    else {
      return Column(
        children: [
          SizedBox(height: 15),
          Text(
            "Uploading... $uploadPercent%",
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
        ],
      );
    }
  }
  Future<bool> confirmUpload() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Upload this month's data?"),
          content: new Text("Please wait until loading is finished before exiting the app."),
          actions: <Widget>[
            new TextButton(
              child: new Text("CANCEL", style: TextStyle(fontSize: 15,),),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            new TextButton(
              child: new Text("UPLOAD", style: TextStyle(fontSize: 15,),),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> gatherMonthData() async {
    for (int i = 0; i < lastDayOfMonth.day + 1; i++) {
      // current day to read => goes from beginning to end of month
      DateTime dayBegin = firstDayOfMonth.subtract(Duration(days: 1)).add(Duration(days: i));
      DateTime dayEnd = new DateTime(dayBegin.year, dayBegin.month, dayBegin.day, 23, 59, 59);


      // data structures
      List<HealthDataPoint> dataDay = [];
        // heart
      Map<int, List<int>> heartratesMap = {};
      List<int> heartrates = [];
      List<int> heartratesWalking = [];
      List<int> heartratesResting = [];
        // step
      int totalSteps = 0;
      int totalDistance = 0;
      Map<int, List<int>> stepsMap = {};
      Map<int, List<int>> distanceMap = {};
        // activity
      int energyBurned = 0;
      int movementMins = 0;
      Map<int, List<int>> energyBurnedMap = {};
      Map<int, List<int>> moveMinsMap = {};
        // sleep
      List<int> sleepTime = [];
      List<int> awakeTime = [];
      List<int> inBedTime = [];


      // READ data using healthkit
      List<HealthDataPoint> healthDataDay = await health.getHealthDataFromTypes(dayBegin, dayEnd, types);
      dataDay.addAll(healthDataDay);
      // WRITE data into data structures
      for (var i = 0; i < dataDay.length; i++) {
        DateTime date = dataDay[i].dateTo;
        int value = dataDay[i].value.floor();

        // HEART
        if (dataDay[i].type == HealthDataType.WALKING_HEART_RATE) heartratesWalking.add(value);
        if (dataDay[i].type == HealthDataType.RESTING_HEART_RATE) heartratesResting.add(value);
        if (dataDay[i].type == HealthDataType.HEART_RATE) {
          heartrates.add(value);
          if (!heartratesMap.containsKey(date.hour)) heartratesMap[date.hour] = [];
          heartratesMap[date.hour] = heartratesMap[date.hour]..addAll([value]);
        }

        // STEP
        if (dataDay[i].type == HealthDataType.STEPS) {
          totalSteps += value;
          if (!stepsMap.containsKey(date.hour)) stepsMap[date.hour] = [];
          stepsMap[date.hour] = stepsMap[date.hour]..addAll([value]);
        }
        if (dataDay[i].type == HealthDataType.DISTANCE_DELTA) {
          totalDistance += value;
          if (!distanceMap.containsKey(date.hour)) distanceMap[date.hour] = [];
          distanceMap[date.hour] = distanceMap[date.hour]..addAll([value]);
        }

        // ACTIVITY
        if (dataDay[i].type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          if (date != dayEnd) {
            if (!energyBurnedMap.containsKey(date.hour)) energyBurnedMap[date.hour] = [];
            else {
              energyBurnedMap[date.hour] = energyBurnedMap[date.hour]..addAll([value]);
              energyBurned += value;
            }
          }
        }
        if (dataDay[i].type == HealthDataType.MOVE_MINUTES) {
          movementMins += value;
          if (!moveMinsMap.containsKey(date.hour)) moveMinsMap[date.hour] = [];
          moveMinsMap[date.hour] = moveMinsMap[date.hour]..addAll([value]);
        }

        // SLEEP
        if (dataDay[i].type == HealthDataType.SLEEP_ASLEEP) sleepTime.add(value);
        if (dataDay[i].type == HealthDataType.SLEEP_AWAKE) awakeTime.add(value);
        if (dataDay[i].type == HealthDataType.SLEEP_IN_BED) inBedTime.add(value);
      }


      // add empty data structures (to avoid empty list errors)
        // heart
      if (heartrates.isEmpty) heartrates.add(0);
      if (heartratesWalking.isEmpty) heartratesWalking.add(0);
      if (heartratesResting.isEmpty) heartratesResting.add(0);
        // sleep
      if (sleepTime.isEmpty) sleepTime.add(0);
      if (awakeTime.isEmpty) awakeTime.add(0);
      if (inBedTime.isEmpty) inBedTime.add(0);


      // save month's data into firestore
        // heart
      if (heartrates.reduce((a,b) => a+b) != 0)
        await firestoreHeart(dayBegin, heartratesMap, heartrates, heartratesResting, heartratesWalking);
        // step
      if (totalSteps != 0 && totalDistance != 0)
        await firestoreStep(dayBegin, totalSteps, totalDistance, stepsMap, distanceMap);
        // activity
      if (energyBurned != 0 && movementMins != 0)
        await firestoreActivity(dayBegin, energyBurned, movementMins, energyBurnedMap, moveMinsMap);
        // sleep
      if (sleepTime.reduce((a,b) => a+b) != 0)
        await firestoreSleep(dayBegin, sleepTime, awakeTime, inBedTime);


      setState(() { uploadPercent =  ((i / (lastDayOfMonth.day + 1)) * 100).floor(); });
      print("___________________\n$dayBegin - $dayEnd");
    }
    setState(() {
      uploading = false;
      uploadPercent = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    askPermissions();
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
              SizedBox(height: 50.0),
              Icon(
                Icons.watch,
                color: Colors.white,
                size: 100,
              ),

              SizedBox(height: 60.0),
              Text(
                "Choose a metric.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: "mont-med",
                ),
              ),

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
              uploadButton(),
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
