import 'package:intl/intl.dart';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'package:tinnitus_app/main.dart';
import '../../../FirestoreService.dart';
import 'package:health/health.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_util/date_util.dart';

class StepsPage extends StatefulWidget {
  @override
  _StepsPageState createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  // data structures for when setting data
  List<HealthDataPoint> _allDataDay = [];
  List<HealthDataPoint> _allDataWeek = [];
  List<HealthDataPoint> _allDataMonth = [];

  // metrics variables
    // day
  int _stepsDay = 0;
  int _distanceDay = 0;
    // week
  int _stepsWeek = 0;
  int _distanceWeek = 0;
    // month
  int _stepsMonth = 0;
  int _distanceMonth = 0;

  // map distance for Firestore
  Map<int, List<int>> _mapDistance = {};

  // graph data structures
  List<StepRate> _graphDay = [];
  Map<int, List<int>> _mapDay = {};
  List<StepRate> _graphWeek = [];
  Map<int, List<int>> _mapWeek = {};
  List<StepRate> _graphMonth = [];
  Map<int, List<int>> _mapMonth = {};
  List<StepRate> graphData() {
    if (_daySelected) return _graphDay;
    else if (_weekSelected) return _graphWeek;
    return _graphMonth;
  }

  Future getStepData(List<HealthDataType> types) async {
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

          if (_allDataDay[i].type == HealthDataType.DISTANCE_DELTA) {
            _distanceDay += value;
            if (!_mapDistance.containsKey(date.hour)) _mapDistance[date.hour] = [];
            _mapDistance[date.hour] = _mapDistance[date.hour]..addAll([value]);
          }
          if (_allDataDay[i].type == HealthDataType.STEPS) {
            _stepsDay += value;
            if (!_mapDay.containsKey(date.hour)) _mapDay[date.hour] = [];
            _mapDay[date.hour] = _mapDay[date.hour]..addAll([value]);
            _graphDay.add(new StepRate(date, _stepsDay));
          }
        }

        // WEEK'S DATA
        List<HealthDataPoint> healthDataWeek = await health.getHealthDataFromTypes(firstDayOfWeek, lastDayOfWeek, types);
        _allDataWeek.addAll(healthDataWeek);
        for (var i = 0; i < _allDataWeek.length; i++) {
          DateTime date = _allDataWeek[i].dateTo;
          int value = _allDataWeek[i].value.floor();

          if (_allDataWeek[i].type == HealthDataType.DISTANCE_DELTA) _distanceWeek += value;
          if (_allDataWeek[i].type == HealthDataType.STEPS) {
            _stepsWeek += value;
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

          if (_allDataMonth[i].type == HealthDataType.DISTANCE_DELTA) _distanceMonth += value;
          if (_allDataMonth[i].type == HealthDataType.STEPS) {
            _stepsMonth += value;
            if (!_mapMonth.containsKey(date.day)) _mapMonth[date.day] = [];
            _mapMonth[date.day] = _mapMonth[date.day]..addAll([value]);
          }
        }

        // create graph data
          // week
        for (int i = 0; i < 7; i++) {
          DateTime temp = firstDayOfWeek.add(Duration(days: i));
          if (_mapWeek.containsKey(temp.day)) {
            List<int> value = _mapWeek[temp.day];
            if (value.isNotEmpty) {
              DateTime date = new DateTime(temp.year, temp.month, temp.day);
              int sum = value.reduce((a, b) => a + b);
              _graphWeek.add(new StepRate(date, sum));
            }
          }
        }
          // month
        _mapMonth.forEach((k, v) {
          if (v.isNotEmpty) {
            DateTime date = new DateTime(firstDayOfMonth.year, firstDayOfMonth.month, k);
            int sum = v.reduce((a, b) => a + b);
            _graphMonth.add(new StepRate(date, sum));
          }
        });

        // upload data to Firestore
        await firestore();

      } catch (e) {}
    } else print("Authorization not granted");
    setState(() {});
  }
  Future firestore() async {
    String uid = user.email;

    // FEATURES
    int steps = _stepsDay;
    int distance = _distanceDay;
    await FirestoreService(uid: uid).stepFeatures(day, steps, distance);

    // HOURLY STEP RATE
    int accSteps = 0;
    Map<String, int> hourlySteps = {};
    _mapDay.forEach((k, v) {
      String time = DateFormat('HH:mm').format(DateTime(day.year, day.month, day.day, k)).toString();
      accSteps += v.reduce((a,b) => a+b);
      hourlySteps.addAll({time: accSteps});
    });
    await FirestoreService(uid: uid).hourlySteps(day, hourlySteps);

    // HOURLY DISTANCE
    int accDistance = 0;
    Map<String, int> hourlyDistance = {};
    _mapDistance.forEach((k, v) {
      String time = DateFormat('HH:mm').format(DateTime(day.year, day.month, day.day, k)).toString();
      accDistance += v.reduce((a,b) => a+b);
      hourlyDistance.addAll({time: accDistance});
    });
    await FirestoreService(uid: uid).hourlyDistance(day, hourlyDistance);
  }

  @override
  void initState() {
    super.initState();

    // instantiate types to read
    List<HealthDataType> types = [
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_DELTA,
    ];

    // read data types
    getStepData(types);

    // fill in rest of day - for graph
    for (int i = 0; i <= 23; i++) {
      DateTime fillerDateWeek = DateTime(day.year, day.month, day.day, i);
      _graphDay.add(new StepRate(fillerDateWeek, null));
    }
    // fill in rest of week - for graph
    for (int i = 0; i < 7; i++) {
      DateTime fillerDateWeek = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day).add(Duration(days: i));
      _graphWeek.add(new StepRate(fillerDateWeek, null));
    }
    // fill in rest of month - for graph
    for (int i = 0; i < DateUtil().daysInMonth(firstDayOfMonth.month, firstDayOfMonth.year); i++) {
      DateTime fillerDateMonth = DateTime(firstDayOfMonth.year, firstDayOfMonth.month, firstDayOfMonth.day).add(Duration(days: i));
      _graphMonth.add(new StepRate(fillerDateMonth, null));
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
  Widget metrics(String _text, EdgeInsetsGeometry _insets, String _metric, int _measure) {
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
        Text("$_measure $_metric",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20
          ),
        ),
      ],
    );
  }
  Widget highlights() {
    if (_daySelected) {
      return Column(children: [
        metrics("Total Step Counts:", EdgeInsets.fromLTRB(18, 0, 60, 2.5), "steps", _stepsDay),
        SizedBox(height: 10),
        metrics("Total Distance Walked:", EdgeInsets.fromLTRB(18, 0, 17, 2.5), "meters", _distanceDay),
      ],);
    }
    else if (_weekSelected) {
      return Column(children: [
        metrics("Total Step Counts:", EdgeInsets.fromLTRB(18, 0, 60, 2.5), "steps", _stepsWeek),
        SizedBox(height: 10),
        metrics("Total Distance Walked:", EdgeInsets.fromLTRB(18, 0, 17, 2.5), "meters", _distanceWeek),
      ],);
    }
    else if (_monthSelected) {
      return Column(children: [
        metrics("Total Step Counts:", EdgeInsets.fromLTRB(18, 0, 60, 2.5), "steps", _stepsMonth),
        SizedBox(height: 10),
        metrics("Total Distance Walked:", EdgeInsets.fromLTRB(18, 0, 17, 2.5), "meters", _distanceMonth),
      ],);
    }
    return Text("Error");
  }

  @override
  Widget build(BuildContext context) {
    var _seriesData = [
      charts.Series<StepRate, DateTime>(
        id: 'Step',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (StepRate i, _) => i.date,
        measureFn: (StepRate i, _) => i.steps,
        data: graphData(),
      )
    ];

    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Step'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
        actions: [
          IconButton(
            splashRadius: 0.01,
            onPressed: () {},
            icon: Icon(
              Icons.directions_run,
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
                'Step Counts (steps)',
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

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _mapDistance.forEach((key, value) {
      //       print("$key - $value");
      //     });
      //   },
      // ),

    );
  }
}

class StepRate {
  DateTime date;
  int steps;

  StepRate(this.date, this.steps);
}