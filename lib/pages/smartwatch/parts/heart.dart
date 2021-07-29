import 'package:flutter/material.dart';
import 'package:fit_kit/fit_kit.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class HeartPage extends StatefulWidget {
  @override
  _HeartPageState createState() => _HeartPageState();
}

class _HeartPageState extends State<HeartPage> {
  // ignore: deprecated_member_use
  List<charts.Series<HeartRate, String>> _seriesData = List<charts.Series<HeartRate, String>>();

  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  var dataDaily = [
    new HeartRate('7/26', 68),
  ];
  var dataWeekly = [
    new HeartRate('7/25', 68),
    new HeartRate('7/26', 68),
    new HeartRate('7/27', 68),
    new HeartRate('7/28', 68),
    new HeartRate('7/29', 68),
    new HeartRate('7/30', 68),
    new HeartRate('7/31', 68),
  ];
  var dataMonthly = [
    new HeartRate('7/1', 68),
    new HeartRate('7/8', 68),
    new HeartRate('7/15', 68),
    new HeartRate('7/22', 68),
    new HeartRate('7/29', 68),
    new HeartRate('7/31', 68),
  ];
  List<HeartRate> data() {
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

          _seriesData[0] = charts.Series(
              id: 'Heart',
              domainFn: (HeartRate i, _) => i.date,
              measureFn: (HeartRate i, _) => i.heartrate,
              data: data(),
              fillPatternFn: (_, __) => charts.FillPatternType.solid,
              fillColorFn: (HeartRate i, _) =>
                  charts.ColorUtil.fromDartColor(Colors.amberAccent),
              labelAccessorFn: (HeartRate i, _) => i.heartrate.toString()
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
          fontSize: 16,
          color: Color.fromRGBO(255, 255, 255, 0.9),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _seriesData.add(
      charts.Series(
        id: 'Heart',
        domainFn: (HeartRate i, _) => i.date,
        measureFn: (HeartRate i, _) => i.heartrate,
        data: data(),
        fillPatternFn: (_, __) => charts.FillPatternType.solid,
        fillColorFn: (HeartRate i, _) =>
            charts.ColorUtil.fromDartColor(Colors.amberAccent),
        labelAccessorFn: (HeartRate i, _) => i.heartrate.toString()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.fromLTRB(15, 20, 15, 80),
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
                child: charts.BarChart(
                  _seriesData,
                  animate: true,
                  animationDuration: Duration(seconds: 1),

                  // change style of x axis
                  domainAxis: new charts.OrdinalAxisSpec(
                      renderSpec: new charts.SmallTickRendererSpec(
                        // Tick and Label styling here.
                          labelStyle: new charts.TextStyleSpec(
                            fontSize: 15, // size in Pts.
                            color: charts.MaterialPalette.white),

                        // Change the line colors to match text color.
                        lineStyle: new charts.LineStyleSpec(
                            color: charts.MaterialPalette.white)
                      )
                  ),

                  // change style of y axis
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                    renderSpec: new charts.GridlineRendererSpec(
                      // Tick and Label styling here.
                        labelStyle: new charts.TextStyleSpec(
                            fontSize: 15, // size in Pts.
                            color: charts.MaterialPalette.white),

                        // Change the line colors to match text color.
                        lineStyle: new charts.LineStyleSpec(
                            color: charts.MaterialPalette.white)
                    )
                  ),

                  defaultRenderer: new charts.BarRendererConfig(
                    barRendererDecorator: new charts.BarLabelDecorator<String>(
                      labelPosition: charts.BarLabelPosition.inside,
                      insideLabelStyleSpec: charts.TextStyleSpec(
                        // color: charts.Color.fromHex(code: '#0096FF'),
                        color: charts.Color.black,
                        fontSize: 21,
                      )
                    ),
                  ),

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
              metric("Maximum Heart Rate: ", EdgeInsets.fromLTRB(18, 0, 173, 0)),
              SizedBox(height: 10),
              metric("Minimum Heart Rate: ", EdgeInsets.fromLTRB(18, 0, 170, 0)),
              SizedBox(height: 10),
              metric("Resting Heart Rate: ", EdgeInsets.fromLTRB(18, 0, 154, 0)),
              SizedBox(height: 10),
              metric("Walking Heart Rate: ", EdgeInsets.fromLTRB(18, 0, 159, 0)),

            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          String date = DateFormat('M/dd').format(DateTime.now());
          print("date: $date");
        },
        child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
      ),

    );
  }
}

class HeartRate {
  String date;
  int heartrate;

  HeartRate(this.date, this.heartrate);
}
