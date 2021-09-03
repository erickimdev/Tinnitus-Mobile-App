import 'utils.dart';
import 'package:flutter/material.dart';
import 'package:tinnitus_app/main.dart';
import '../../../FirestoreService.dart';
import 'package:health/health.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_util/date_util.dart';

class SleepPage extends StatefulWidget {
  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
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
  List<int> _sleepDay = [];
  List<int> _timeAwakeDay = [];
  List<int> _timeInBedDay = [];
    // week
  List<int> _sleepWeek = [];
  List<int> _timeAwakeWeek = [];
  List<int> _timeInBedWeek = [];
    // month
  List<int> _sleepMonth = [];
  List<int> _timeAwakeMonth = [];
  List<int> _timeInBedMonth = [];

  // graph data structures
  List<SleepRate> _graphDay = [];
  List<SleepRate> _graphWeek = [];
  List<SleepRate> _graphMonth = [];
  List<SleepRate> graphData() {
    if (_daySelected) return _graphDay;
    else if (_weekSelected) return _graphWeek;
    else return _graphMonth;
  }

  Future getSleepData(List<HealthDataType> types) async {
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

          if (_allDataDay[i].type == HealthDataType.SLEEP_AWAKE) _timeAwakeDay.add(value);
          if (_allDataDay[i].type == HealthDataType.SLEEP_IN_BED) _timeInBedDay.add(value);
          if (_allDataDay[i].type == HealthDataType.SLEEP_ASLEEP) {
            _sleepDay.add(value);
            _graphDay.add(new SleepRate(date, value));
          }
        }

        // WEEK'S DATA
        List<HealthDataPoint> healthDataWeek = await health.getHealthDataFromTypes(firstDayOfWeek, lastDayOfWeek, types);
        _allDataWeek.addAll(healthDataWeek);
        for (var i = 0; i < _allDataWeek.length; i++) {
          DateTime date = _allDataWeek[i].dateTo;
          int value = _allDataWeek[i].value.floor();

          if (_allDataWeek[i].type == HealthDataType.SLEEP_AWAKE) _timeAwakeWeek.add(value);
          if (_allDataWeek[i].type == HealthDataType.SLEEP_IN_BED) _timeInBedWeek.add(value);
          if (_allDataWeek[i].type == HealthDataType.SLEEP_ASLEEP) {
            _sleepWeek.add(value);
            _graphWeek.add(new SleepRate(date, value));
          }
        }

        // MONTH'S DATA
        List<HealthDataPoint> healthDataMonth = await health.getHealthDataFromTypes(firstDayOfMonth, lastDayOfMonth, types);
        _allDataMonth.addAll(healthDataMonth);
        for (var i = 0; i < _allDataMonth.length; i++) {
          DateTime date = _allDataMonth[i].dateTo;
          int value = _allDataMonth[i].value.floor();

          if (_allDataMonth[i].type == HealthDataType.SLEEP_AWAKE) _timeAwakeMonth.add(value);
          if (_allDataMonth[i].type == HealthDataType.SLEEP_IN_BED) _timeInBedMonth.add(value);
          if (_allDataMonth[i].type == HealthDataType.SLEEP_ASLEEP) {
            _sleepMonth.add(value);
            _graphMonth.add(new SleepRate(date, value));
          }
        }

        // update metrics data structures if no data
          // day
        if (_sleepDay.isEmpty) _sleepDay.add(0);
        if (_timeAwakeDay.isEmpty) _timeAwakeDay.add(0);
        if (_timeInBedDay.isEmpty) _timeInBedDay.add(0);
          // week
        if (_sleepWeek.isEmpty) _sleepWeek.add(0);
        if (_timeAwakeWeek.isEmpty) _timeAwakeWeek.add(0);
        if (_timeInBedWeek.isEmpty) _timeInBedWeek.add(0);
          // month
        if (_sleepMonth.isEmpty) _sleepMonth.add(0);
        if (_timeAwakeMonth.isEmpty) _timeAwakeMonth.add(0);
        if (_timeInBedMonth.isEmpty) _timeInBedMonth.add(0);

      } catch (e) {}
    } else print("Authorization not granted");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // upload data to Firestore
    gatherData(day.day, day.day + 1);

    // instantiate types to read
    List<HealthDataType> types = [
      // HealthDataType.SLEEP_ASLEEP,     // NOT AVAILABLE ON ANDROID
      // HealthDataType.SLEEP_AWAKE,      // NOT AVAILABLE ON ANDROID
      // HealthDataType.SLEEP_IN_BED,     // NOT AVAILABLE ON ANDROID
    ];

    // read data types
    getSleepData(types);

    // fill in rest of day - for graph
    for (int i = 0; i <= 23; i++) {
      DateTime fillerDateWeek = DateTime(day.year, day.month, day.day, i);
      _graphDay.add(new SleepRate(fillerDateWeek, null));
    }
    // fill in rest of week - for graph
    for (int i = 0; i < 7; i++) {
      DateTime fillerDateWeek = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day).add(Duration(days: i));
      _graphWeek.add(new SleepRate(fillerDateWeek, null));
    }
    // fill in rest of month - for graph
    for (int i = 0; i < DateUtil().daysInMonth(firstDayOfMonth.month, firstDayOfMonth.year); i++) {
      DateTime fillerDateMonth = DateTime(firstDayOfMonth.year, firstDayOfMonth.month, firstDayOfMonth.day).add(Duration(days: i));
      _graphMonth.add(new SleepRate(fillerDateMonth, null));
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
        Text("$_measure minutes",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20
          ),
        ),
      ],
    );
  }
  Widget highlights() {
    if (_sleepDay.isEmpty || _sleepWeek.isEmpty || _sleepMonth.isEmpty) return CircularProgressIndicator();

    // calculate metrics based off data structures
    int _awakeDay = _timeAwakeDay.reduce((a,b) => a+b).toDouble() ~/ _timeAwakeDay.length;
    int _inBedDay = _timeInBedDay.reduce((a,b) => a+b).toDouble() ~/ _timeInBedDay.length;
    int _awakeWeek = _timeAwakeWeek.reduce((a,b) => a+b).toDouble() ~/ _timeAwakeWeek.length;
    int _inBedWeek = _timeInBedWeek.reduce((a,b) => a+b).toDouble() ~/ _timeInBedWeek.length;
    int _awakeMonth = _timeAwakeMonth.reduce((a,b) => a+b).toDouble() ~/ _timeAwakeMonth.length;
    int _inBedMonth = _timeInBedMonth.reduce((a,b) => a+b).toDouble() ~/ _timeInBedMonth.length;

    if (_daySelected) {
      return Column(children: [
        metrics("Time Asleep:", EdgeInsets.fromLTRB(19, 0, 10, 2.5), _sleepDay.reduce((a,b) => a+b)),
        SizedBox(height: 10),
        metrics("Time Awake:", EdgeInsets.fromLTRB(19, 0, 10, 2.5), _awakeDay.floor()),
        SizedBox(height: 10),
        metrics("Time in Bed:", EdgeInsets.fromLTRB(19, 0, 12, 2.5), _inBedDay.floor()),
      ],);
    }
    else if (_weekSelected) {
      return Column(children: [
        metrics("Time Asleep:", EdgeInsets.fromLTRB(19, 0, 10, 2.5), _sleepWeek.reduce((a,b) => a+b)),
        SizedBox(height: 10),
        metrics("Time Awake:", EdgeInsets.fromLTRB(19, 0, 10, 2.5), _awakeWeek.floor()),
        SizedBox(height: 10),
        metrics("Time in Bed:", EdgeInsets.fromLTRB(19, 0, 12, 2.5), _inBedWeek.floor()),
      ],);
    }
    else if (_monthSelected) {
      return Column(children: [
        metrics("Time Asleep:", EdgeInsets.fromLTRB(19, 0, 10, 2.5), _sleepMonth.reduce((a,b) => a+b)),
        SizedBox(height: 10),
        metrics("Time Awake:", EdgeInsets.fromLTRB(19, 0, 10, 2.5), _awakeMonth.floor()),
        SizedBox(height: 10),
        metrics("Time in Bed:", EdgeInsets.fromLTRB(19, 0, 12, 2.5), _inBedMonth.floor()),
      ],);
    }
    return Text("Error");
  }

  @override
  Widget build(BuildContext context) {
    var _seriesData = [
      charts.Series<SleepRate, DateTime>(
        id: 'Sleep',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (SleepRate i, _) => i.date,
        measureFn: (SleepRate i, _) => i.sleeprate,
        data: graphData(),
      )
    ];

    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Sleep'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
        actions: [
          IconButton(
            splashRadius: 0.01,
            onPressed: () {},
            icon: Icon(
              Icons.bedtime_rounded,
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
                'Sleep Time (minutes)',
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
      //   onPressed: () async {
      //   },
      // ),

    );
  }
}

class SleepRate {
  DateTime date;
  int sleeprate;

  SleepRate(this.date, this.sleeprate);
}