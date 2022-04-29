import '../utils.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'dart:math';
import '../../../FirestoreService.dart';
import '../../../main.dart';


class HeartPage extends StatefulWidget {
  @override
  _HeartPageState createState() => _HeartPageState();
}

class _HeartPageState extends State<HeartPage> with SingleTickerProviderStateMixin {
  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  void updateFirestore() async {
    int avg_hr = heart_day_heartrate.reduce((a,b)=>a+b).toDouble() ~/ heart_day_heartrate.length;
    int max_hr = heart_day_heartrate.reduce(max);
    int min_hr = heart_day_heartrate.reduce(min);
    await FirestoreService(uid: "${user.email}").heartFeatures(day, avg_hr, max_hr, min_hr);
    await FirestoreService(uid: "${user.email}").hourlyHeartRate(day, firestore_hr);
  }

  @override
  void initState() {
    updateFirestore();

    super.initState();
  }


  Widget timeButton(String _text, EdgeInsetsGeometry _insets, bool selected) {
    ButtonStyle buttonStyle = selected ? ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[800]))
        : ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue));
    return OutlinedButton(
        style: buttonStyle,
        onPressed: () {
          if ((_text == "Day" && _highlights != "DAILY HIGHLIGHTS")
          || (_text == "Week" && _highlights != "WEEKLY HIGHLIGHTS")
          || (_text == "Month" && _highlights != "MONTHLY HIGHLIGHTS")) {
            setState(() {
              if (_text == "Day") {
                _daySelected = true;
                _weekSelected = false;
                _monthSelected = false;
                _highlights = "DAILY HIGHLIGHTS";
              }
              else if (_text == "Week") {
                _daySelected = false;
                _weekSelected = true;
                _monthSelected = false;
                _highlights = "WEEKLY HIGHLIGHTS";
              }
              else if (_text == "Month") {
                _daySelected = false;
                _weekSelected = false;
                _monthSelected = true;
                _highlights = "MONTHLY HIGHLIGHTS";
              }
            });
          }
        },
        child: Padding(
          padding: _insets,
          child: Text(
            _text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        )
    );
  }
  Widget barGraph() {
    List<charts.Series<GraphData, DateTime>> data;
      if (_daySelected) data = heart_dayData;
      else if (_weekSelected) data = heart_weekdata;
      else if (_monthSelected) data = heart_monthdata;

    return SingleChildScrollView(
        child: SizedBox(
          height: 360,
          child: new charts.TimeSeriesChart(
              data,
              animate: false,
              defaultRenderer: new charts.LineRendererConfig<DateTime>(),

              // change style of x axis
              domainAxis: new charts.DateTimeAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                      axisLineStyle: charts.LineStyleSpec(
                        color: charts.MaterialPalette.white,
                      ),
                      labelStyle: new charts.TextStyleSpec(
                        fontSize: 14,
                        color: charts.MaterialPalette.white,
                      ),
                      lineStyle: charts.LineStyleSpec(
                        thickness: 0,
                        color: charts.MaterialPalette.gray.shade400,
                      )
                  ),
                  tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                      hour: new charts.TimeFormatterSpec(
                        format: 'HH:mm',
                        transitionFormat: 'HH:mm',
                      )
                  )
              ),

              // change style of y axis
              primaryMeasureAxis: charts.NumericAxisSpec(
                // tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false),
                  renderSpec: charts.GridlineRendererSpec(
                      labelStyle: charts.TextStyleSpec(
                          fontSize: 15, color: charts.MaterialPalette.white),
                      lineStyle: charts.LineStyleSpec(
                          thickness: 1,
                          color: charts.MaterialPalette.gray.shade300)))

          ),
        )
    );
  }
  Widget metrics(String _text, EdgeInsetsGeometry _insets, int metric, String unit) {
    return Row(
      children: [
        SizedBox(width: 18),
        Padding(
          padding: _insets,
          child: Text(
            _text,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 18,
              color: Color.fromRGBO(255, 255, 255, 0.9),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          verticalDirection: VerticalDirection.up,
          children: <Widget>[
            Text("$metric $unit", style: TextStyle(fontSize: 18, color: Color.fromRGBO(255, 255, 255, 0.9),)),
          ],
        ),
      ],
    );
  }
  Widget highlights() {
    if (_daySelected) {
      int day_avg = heart_day_heartrate.reduce((a,b)=>a+b).toDouble() ~/ heart_day_heartrate.length;

      return Column(children: [
        SizedBox(height: 10),
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 65, 2.5), heart_day_heartrate.reduce(max), "BPM"),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 70, 2.5), heart_day_heartrate.reduce(min), "BPM"),
        SizedBox(height: 10),
        metrics("Average Heart Rate:", EdgeInsets.fromLTRB(0, 0, 86, 2.5), day_avg, "BPM"),
      ],);
    }
    else if (_weekSelected) {
      int week_avg = heart_week_heartrate.reduce((a,b)=>a+b).toDouble() ~/ heart_week_heartrate.length;

      return Column(children: [
        SizedBox(height: 10),
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 65, 2.5), heart_week_heartrate.reduce(max), "BPM"),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 70, 2.5), heart_week_heartrate.reduce(min), "BPM"),
        SizedBox(height: 10),
        metrics("Average Heart Rate:", EdgeInsets.fromLTRB(0, 0, 86, 2.5), week_avg, "BPM"),
      ],);
    }
    else if (_monthSelected) {
      int month_avg = heart_month_heartrate.reduce((a,b)=>a+b).toDouble() ~/ heart_month_heartrate.length;

      return Column(children: [
        SizedBox(height: 10),
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 65, 2.5), heart_month_heartrate.reduce(max), "BPM"),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 70, 2.5), heart_month_heartrate.reduce(min), "BPM"),
        SizedBox(height: 10),
        metrics("Average Heart Rate:", EdgeInsets.fromLTRB(0, 0, 86, 2.5), month_avg, "BPM"),
      ],);
    }
    return Text("Error");
  }


  @override
  Widget build(BuildContext context) {
    if (heart_dayData == null) return CircularProgressIndicator();
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),
      appBar: AppBar(
        title: Text('Heart'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
        actions: [
          IconButton(
            splashRadius: 0.01,
            onPressed: () {},
            icon: Icon(
              Icons.favorite,
              size: 30,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 20, 15, 70),
          child: Center(
            child: Column(
              children: <Widget>[
                // DAY-WEEK-MONTH buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // DAY BUTTON
                    timeButton("Day", EdgeInsets.fromLTRB(14, 8, 14, 8), _daySelected),

                    // WEEK BUTTON
                    SizedBox(width: 10),
                    timeButton("Week", EdgeInsets.fromLTRB(6, 8, 6, 8), _weekSelected),

                    // MONTH BUTTON
                    SizedBox(width: 10),
                    timeButton("Month", EdgeInsets.fromLTRB(0, 8, 0, 8), _monthSelected),
                  ],
                ),

                // bar graph
                SizedBox(height: 20),
                Text(
                  'Average Heart Rate (bpm)',
                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 17),
                ),
                barGraph(),

                // "... HIGHLIGHTS" text & line
                SizedBox(height: 50.0),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(17, 0, 0, 0),
                      child: Text(
                        _highlights,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(255, 255, 255, 0.9),
                            fontFamily: 'mont'
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.white, thickness: 1.3, height: 0, indent: 20, endIndent: 20),

                // actual metrics highlights
                SizedBox(height: 15),
                highlights(),
              ],
            ),
          ),
        ),
      ),


      // // region DEBUG BUTTON
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     heart_day_heartrate.forEach((element) {
      //       print(element);
      //     });
      //   },
      // ),
      // //endregion


    );
  }
}