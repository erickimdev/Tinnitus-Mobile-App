import 'package:intl/intl.dart';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'package:tinnitus_app/main.dart';
import '../../../FirestoreService.dart';
import 'package:health/health.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_util/date_util.dart';
import 'dart:math';

class HeartPage extends StatefulWidget {
  @override
  _HeartPageState createState() => _HeartPageState();
}

class _HeartPageState extends State<HeartPage> {
  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  // data structures for when setting data
  List<HealthDataPoint> _allDataDay = [];
  List<HealthDataPoint> _allDataWeek = [];
  List<HealthDataPoint> _allDataMonth = [];

  // metrics data structures
    // day
  List<int> _HRsDay = [];
  List<int> _restHRsDay = [];
  List<int> _walkHRsDay = [];
    // week
  List<int> _HRsWeek = [];
  List<int> _restHRsWeek = [];
  List<int> _walkHRsWeek = [];
    // month
  List<int> _HRsMonth = [];
  List<int> _restHRsMonth = [];
  List<int> _walkHRsMonth = [];

  // graph data structures
  List<HeartRate> _graphDay = [];
  Map<int, List<int>> _mapDay = {};
  List<HeartRate> _graphWeek = [];
  Map<int, List<int>> _mapWeek = {};
  List<HeartRate> _graphMonth = [];
  Map<int, List<int>> _mapMonth = {};
  List<HeartRate> graphData() {
    if (_daySelected) return _graphDay;
    else if (_weekSelected) return _graphWeek;
    return _graphMonth;
  }

  Future getHeartData(List<HealthDataType> types) async {
    setState(() {return CircularProgressIndicator;});

    bool healthPermissionsGranted = await health.requestAuthorization(types);
    if (healthPermissionsGranted) {
      try {

        // DAY'S DATA
        List<HealthDataPoint> healthDataDay = await health.getHealthDataFromTypes(dayBegin, dayEnd, types);
        _allDataDay.addAll(healthDataDay);
        for (var i = 0; i < _allDataDay.length; i++) {
          DateTime date = _allDataDay[i].dateTo;
          int value = _allDataDay[i].value.floor();

          if (_allDataDay[i].type == HealthDataType.RESTING_HEART_RATE) _restHRsDay.add(value);
          if (_allDataDay[i].type == HealthDataType.WALKING_HEART_RATE) _walkHRsDay.add(value);
          if (_allDataDay[i].type == HealthDataType.HEART_RATE) {
            _HRsDay.add(value);
            if (!_mapDay.containsKey(date.hour)) _mapDay[date.hour] = [];
            _mapDay[date.hour] = _mapDay[date.hour]..addAll([value]);
          }
        }

        // WEEK'S DATA
        List<HealthDataPoint> healthDataWeek = await health.getHealthDataFromTypes(firstDayOfWeek, lastDayOfWeek, types);
        _allDataWeek.addAll(healthDataWeek);
        for (var i = 0; i < _allDataWeek.length; i++) {
          DateTime date = _allDataWeek[i].dateTo;
          int value = _allDataWeek[i].value.floor();

          if (_allDataWeek[i].type == HealthDataType.RESTING_HEART_RATE) _restHRsWeek.add(value);
          if (_allDataWeek[i].type == HealthDataType.WALKING_HEART_RATE) _walkHRsWeek.add(value);
          if (_allDataWeek[i].type == HealthDataType.HEART_RATE) {
            _HRsWeek.add(value);
            if (!_mapWeek.containsKey(date.day)) _mapWeek[date.day] = [];
            _mapWeek[date.day] = _mapWeek[date.day]..addAll([value]);
          }
        }

        // MONTH'S DATA
        List<HealthDataPoint> healthDataMonth = await health.getHealthDataFromTypes(firstDayOfMonth, lastDayOfMonth, types);
        _allDataMonth.addAll(healthDataMonth);
        for (var i = 0; i < _allDataMonth.length; i++) {
          DateTime date = _allDataMonth[i].dateTo;
          int value = _allDataMonth[i].value.floor();

          if (_allDataMonth[i].type == HealthDataType.RESTING_HEART_RATE) _restHRsMonth.add(value);
          if (_allDataMonth[i].type == HealthDataType.WALKING_HEART_RATE) _walkHRsMonth.add(value);
          if (_allDataMonth[i].type == HealthDataType.HEART_RATE) {
            _HRsMonth.add(value);
            if (!_mapMonth.containsKey(date.day)) _mapMonth[date.day] = [];
            _mapMonth[date.day] = _mapMonth[date.day]..addAll([value]);
          }
        }


        // create graph data
            // day
        _mapDay.forEach((k, v) {
          if (v.isNotEmpty) {
            DateTime date = new DateTime(dayBegin.year, dayBegin.month, dayBegin.day, k);
            int avg = v.reduce((a, b) => a + b).toDouble() ~/ v.length;
            _graphDay.add(new HeartRate(date, avg));
          }
        });
            // week
        for (int i = 0; i < 7; i++) {
          DateTime temp = firstDayOfWeek.add(Duration(days: i));
          if (_mapWeek.containsKey(temp.day)) {
            List<int> value = _mapWeek[temp.day];
            if (value.isNotEmpty) {
              DateTime date = new DateTime(temp.year, temp.month, temp.day);
              int avg = value.reduce((a, b) => a + b).toDouble() ~/ value.length;
              _graphWeek.add(new HeartRate(date, avg));
            }
          }
        }
            // month
        _mapMonth.forEach((k, v) {
          if (v.isNotEmpty) {
            DateTime date = new DateTime(firstDayOfMonth.year, firstDayOfMonth.month, k);
            int avg = v.reduce((a, b) => a + b).toDouble() ~/ v.length;
            _graphMonth.add(new HeartRate(date, avg));
          }
        });


        // update metrics data structures if no data
          // day
        if (_HRsDay.isEmpty) _HRsDay.add(0);
        if (_restHRsDay.isEmpty) _restHRsDay.add(0);
        if (_walkHRsDay.isEmpty) _walkHRsDay.add(0);
          // week
        if (_HRsWeek.isEmpty) _HRsWeek.add(0);
        if (_restHRsWeek.isEmpty) _restHRsWeek.add(0);
        if (_walkHRsWeek.isEmpty) _walkHRsWeek.add(0);
          // month
        if (_HRsMonth.isEmpty) _HRsMonth.add(0);
        if (_restHRsMonth.isEmpty) _restHRsMonth.add(0);
        if (_walkHRsMonth.isEmpty) _walkHRsMonth.add(0);

        // upload data to Firestore
        await firestore();

      } catch (e) {}
    } else print("Authorization not granted");
    setState(() {});
  }
  Future firestore() async {
    // FEATURES
    int avgHR = _HRsDay.reduce((a,b) => a+b).toDouble() ~/ _HRsDay.length;
    int avgRestingHR = _restHRsDay.reduce((a,b) => a+b).toDouble() ~/ _restHRsDay.length;
    int avgWalkingHR = _walkHRsDay.reduce((a,b) => a+b).toDouble() ~/ _walkHRsDay.length;
    int maxHR = _HRsDay.reduce(max);
    int minHR = _HRsDay.reduce(min);
    await FirestoreService(uid: uid).heartFeatures(day, avgHR, avgRestingHR, avgWalkingHR, maxHR, minHR);

    // HOURLY HEART RATE
    Map<String, int> hourlyHRs = {};
    _mapDay.forEach((k, v) {
      String time = DateFormat('HH:mm').format(DateTime(day.year, day.month, day.day, k)).toString();
      int avg = v.reduce((a,b) => a+b).toDouble() ~/ v.length;
      hourlyHRs.addAll({time: avg});
    });
    await FirestoreService(uid: uid).hourlyHeartRate(day, hourlyHRs);
  }

  @override
  void initState() {
    super.initState();

    // instantiate types to read
    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      // HealthDataType.RESTING_HEART_RATE,   // NOT AVAILABLE ON ANDROID
      // HealthDataType.WALKING_HEART_RATE,   // NOT AVAILABLE ON ANDROID
    ];

    // read data types
    getHeartData(types);

    // fill in rest of day - for graph
    for (int i = 0; i <= 23; i++) {
      DateTime fillerDateWeek = DateTime(day.year, day.month, day.day, i);
      _graphDay.add(new HeartRate(fillerDateWeek, null));
    }
    // fill in rest of week - for graph
    for (int i = 0; i < 7; i++) {
      DateTime fillerDateWeek = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day).add(Duration(days: i));
      _graphWeek.add(new HeartRate(fillerDateWeek, null));
    }
    // fill in rest of month - for graph
    for (int i = 0; i < DateUtil().daysInMonth(firstDayOfMonth.month, firstDayOfMonth.year); i++) {
      DateTime fillerDateMonth = DateTime(firstDayOfMonth.year, firstDayOfMonth.month, firstDayOfMonth.day).add(Duration(days: i));
      _graphMonth.add(new HeartRate(fillerDateMonth, null));
    }
  }


  ButtonStyle buttonStyle(bool selected) {
    if (selected)
      return ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[800]));
    else
      return ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue));
  }
  Widget timeButton(String _text, EdgeInsetsGeometry _insets, bool selected) {
    return OutlinedButton(
        style: buttonStyle(selected),
        onPressed: () {
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
  Widget metrics(String _text, EdgeInsetsGeometry _insets, int _measure) {
    return Row(
      children: [
        Padding(
          padding: _insets,
          child: Text(
            _text,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              color: Color.fromRGBO(255, 255, 255, 0.9),
            ),
          ),
        ),
        SizedBox(width: 0),
        Text("$_measure BPM",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20
          ),
        ),
      ],
    );
  }
  Widget highlights() {
    if (_HRsDay.isEmpty || _HRsWeek.isEmpty || _HRsMonth.isEmpty) return CircularProgressIndicator();

    // calculate metrics based off data structures
    int _restDay = _restHRsDay.reduce((a,b) => a+b).toDouble() ~/ _restHRsDay.length;
    int _walkDay = _walkHRsDay.reduce((a,b) => a+b).toDouble() ~/ _walkHRsDay.length;
    int _restWeek = _restHRsWeek.reduce((a,b) => a+b).toDouble() ~/ _restHRsWeek.length;
    int _walkWeek = _walkHRsWeek.reduce((a,b) => a+b).toDouble() ~/ _walkHRsWeek.length;
    int _restMonth = _restHRsMonth.reduce((a,b) => a+b).toDouble() ~/ _restHRsMonth.length;
    int _walkMonth = _walkHRsMonth.reduce((a,b) => a+b).toDouble() ~/ _walkHRsMonth.length;

    if (_daySelected) {
      return Column(children: [
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(18, 0, 10, 2.5), _HRsDay.reduce(max)),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(18, 0, 14, 2.5), _HRsDay.reduce(min)),
        SizedBox(height: 10),
        metrics("Resting Heart Rate:", EdgeInsets.fromLTRB(18, 0, 33, 2.5), _restDay.floor()),
        SizedBox(height: 10),
        metrics("Walking Heart Rate:", EdgeInsets.fromLTRB(18, 0, 28, 2.5), _walkDay.floor()),
      ],);
    }
    else if (_weekSelected) {
      return Column(children: [
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(18, 0, 10, 2.5), _HRsWeek.reduce(max)),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(18, 0, 14, 2.5), _HRsWeek.reduce(min)),
        SizedBox(height: 10),
        metrics("Resting Heart Rate:", EdgeInsets.fromLTRB(18, 0, 33, 2.5), _restWeek.floor()),
        SizedBox(height: 10),
        metrics("Walking Heart Rate:", EdgeInsets.fromLTRB(18, 0, 28, 2.5), _walkWeek.floor()),
      ],);
    }
    else if (_monthSelected) {
      return Column(children: [
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(18, 0, 10, 2.5), _HRsMonth.reduce(max)),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(18, 0, 14, 2.5), _HRsMonth.reduce(min)),
        SizedBox(height: 10),
        metrics("Resting Heart Rate:", EdgeInsets.fromLTRB(18, 0, 33, 2.5), _restMonth.floor()),
        SizedBox(height: 10),
        metrics("Walking Heart Rate:", EdgeInsets.fromLTRB(18, 0, 28, 2.5), _walkMonth.floor()),
      ],);
    }
    return Text("Error");
  }

  @override
  Widget build(BuildContext context) {
    var _seriesData = [
      charts.Series<HeartRate, DateTime>(
        id: 'Heart',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (HeartRate i, _) => i.date,
        measureFn: (HeartRate i, _) => i.heartrate,
        data: graphData(),
      )
    ];

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

      body: Padding(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 70),
        child: Center(
          child: Column(
            children: <Widget>[
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

              SizedBox(height: 10.0),
              Expanded(
                child: charts.TimeSeriesChart(
                    _seriesData,
                    animate: false,

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
              ),

              SizedBox(height: 12),
              Text(
                'Average Heart Rate (bpm)',
                style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16),
              ),

              SizedBox(height: 35.0),
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

              // HIGHLIGHTS
              SizedBox(height: 25),
              highlights(),

            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
        },
      ),

    );
  }
}

class HeartRate {
  DateTime date;
  int heartrate;

  HeartRate(this.date, this.heartrate);
}