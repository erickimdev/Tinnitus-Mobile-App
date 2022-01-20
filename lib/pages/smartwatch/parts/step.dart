import '../utils.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';


class StepPage extends StatefulWidget {
  @override
  _StepPageState createState() => _StepPageState();
}

class _StepPageState extends State<StepPage> with SingleTickerProviderStateMixin {
  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  @override
  void initState() {
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
    if (_daySelected) data = steps_dayData;
    else if (_weekSelected) data = steps_weekdata;
    else if (_monthSelected) data = steps_monthdata;

    return SingleChildScrollView(
        child: SizedBox(
          height: 375,
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
              fontSize: 19,
              color: Color.fromRGBO(255, 255, 255, 0.9),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          verticalDirection: VerticalDirection.up,
          children: <Widget>[
            Text("$metric $unit", style: TextStyle(fontSize: 19,color: Color.fromRGBO(255, 255, 255, 0.9),)),
          ],
        ),
      ],
    );
  }
  Widget highlights() {
    if (_daySelected) {
      return Column(children: [
        SizedBox(height: 10),
        metrics("Total Step Counts:", EdgeInsets.fromLTRB(0, 0, 55, 2.5), steps_day_steps, "steps"),
        SizedBox(height: 10),
        metrics("Distance Traveled:", EdgeInsets.fromLTRB(0, 0, 52, 2.5), steps_day_distance, "meters"),
      ],);
    }
    else if (_weekSelected) {
      return Column(children: [
        SizedBox(height: 10),
        metrics("Total Step Counts:", EdgeInsets.fromLTRB(0, 0, 55, 2.5), steps_week_steps, "steps"),
        SizedBox(height: 10),
        metrics("Distance Traveled:", EdgeInsets.fromLTRB(0, 0, 52, 2.5), steps_week_distance, "meters"),
      ],);
    }
    else if (_monthSelected) {
      return Column(children: [
        SizedBox(height: 10),
        metrics("Total Step Counts:", EdgeInsets.fromLTRB(0, 0, 55, 2.5), steps_month_steps, "steps"),
        SizedBox(height: 10),
        metrics("Distance Traveled:", EdgeInsets.fromLTRB(0, 0, 52, 2.5), steps_month_distance, "meters"),
      ],);
    }
    return Text("Error");
  }


  @override
  Widget build(BuildContext context) {
    if (steps_dayData == null) return CircularProgressIndicator();
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
                  'Step Counts (# of steps)',
                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 17),
                ),
                barGraph(),

                // "... HIGHLIGHTS" text & line
                SizedBox(height: 60.0),
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
      //     allWeekData.forEach((i) {
      //       int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
      //       int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
      //       String start_date = DateFormat("MM-dd-yyyy HH:mm").format(DateTime.fromMillisecondsSinceEpoch(start));
      //       String end_date = DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(end));
      //
      //       print("$start_date-$end_date: ${i.steps} steps");
      //     });
      //   },
      // ),
      // //endregion


    );
  }
}