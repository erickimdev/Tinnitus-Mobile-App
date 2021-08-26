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
  void askPermissions() async {
    activityPermission = await Permission.activityRecognition.request();
    bool healthPermissionsGranted = await health.requestAuthorization(types);
    if (healthPermissionsGranted && !uploaded) gatherMonthData();
  }

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
              // uploadButton(),
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
