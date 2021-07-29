import 'package:flutter/material.dart';
import 'package:fit_kit/fit_kit.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // ignore: deprecated_member_use
  List<charts.Series<Activity, String>> _seriesPieData = List<charts.Series<Activity, String>>();

  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  var dataDaily = [
    new Activity('Work', 30, Color(0xff3366cc)),
    new Activity('Eat', 15, Color(0xff990099)),
    new Activity('Commute', 10.8, Color(0xff109618)),
    new Activity('TV', 15.6, Color(0xfffdbe19)),
  ];
  var dataWeekly = [
    new Activity('Work', 30, Color(0xff3366cc)),
    new Activity('Eat', 30, Color(0xff990099)),
    new Activity('Commute', 10.8, Color(0xff109618)),
    new Activity('TV', 15.6, Color(0xfffdbe19)),
  ];
  var dataMonthly = [
    new Activity('Work', 30, Color(0xff3366cc)),
    new Activity('Eat', 45, Color(0xff990099)),
    new Activity('Commute', 10.8, Color(0xff109618)),
    new Activity('TV', 15.6, Color(0xfffdbe19)),
  ];
  List<Activity> data() {
    if (_daySelected) return dataDaily;
    else if (_weekSelected) return dataWeekly;
    else return dataMonthly;
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

          // change pie chart data to daily/weekly/monthly
          _seriesPieData[0] = charts.Series(
            id: 'Activities',
            domainFn: (Activity i, _) => i.activity,
            measureFn: (Activity i, _) => i.value,
            colorFn: (Activity i, _) => charts.ColorUtil.fromDartColor(i.color),
            data: data(),
            labelAccessorFn: (Activity i, _) => '${i.value}',
          );
        });
      },
      child: Padding(
        padding: _insets,
        child: Text(
          _text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      )
    );
  }

  Widget metric(String _text, EdgeInsetsGeometry _insets) {
    return Padding(
      padding: _insets,
      child: Text(
        _text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18,
          color: Color.fromRGBO(255, 255, 255, 0.9),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _seriesPieData.add(
      charts.Series(
        id: 'Activities',
        domainFn: (Activity i, _) => i.activity,
        measureFn: (Activity i, _) => i.value,
        colorFn: (Activity i, _) => charts.ColorUtil.fromDartColor(i.color),
        data: data(),
        labelAccessorFn: (Activity i, _) => '${i.value}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Activity'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
        actions: [
          IconButton(
            splashRadius: 0.01,
            onPressed: () {},
            icon: Icon(
              Icons.directions_bike,
              size: 30,
            ),
          )
        ],
      ),

      body: Padding(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 60),
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
                child: charts.PieChart(
                  _seriesPieData,
                  animate: true,
                  animationDuration: Duration(seconds: 1),

                  behaviors: [
                    new charts.DatumLegend(
                      outsideJustification: charts.OutsideJustification.endDrawArea,
                      horizontalFirst: false,
                      desiredMaxRows: 2,
                      cellPadding: new EdgeInsets.only(right: 35.0, bottom: 0.0),
                      entryTextStyle: charts.TextStyleSpec(
                          color: charts.MaterialPalette.white,
                          fontFamily: 'mont-reg',
                          fontSize: 15
                      ),
                    )
                  ],

                  defaultRenderer: new charts.ArcRendererConfig(
                    arcWidth: 100,
                    arcRendererDecorators: [
                      new charts.ArcLabelDecorator(
                        labelPosition: charts.ArcLabelPosition.inside,
                        insideLabelStyleSpec: charts.TextStyleSpec(
                          color: charts.Color.white,
                          fontSize: 17,
                        )
                      ),
                    ],
                  ),

                ),
              ),
              Text(
                'Activity Type (%)',
                style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16),
              ),

              SizedBox(height: 35.0),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
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
              Divider(
                color: Colors.white,
                thickness: 1.3,
                height: 0,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 25),
              metric("Walking distance: ", EdgeInsets.fromLTRB(18, 0, 179, 0)),
              SizedBox(height: 10),
              metric("Cycling distance: ", EdgeInsets.fromLTRB(18, 0, 170, 0)),
              SizedBox(height: 10),
              metric("Workout exercise: ", EdgeInsets.fromLTRB(18, 0, 178, 0)),
              SizedBox(height: 10),
              metric("Location visits: ", EdgeInsets.fromLTRB(18, 0, 150, 0)),

            ],
          ),
        ),
      ),
    );
  }
}

class Activity {
  String activity;
  double value;
  Color color;

  Activity(this.activity, this.value, this.color);
}
