import '../data.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import '../../../services/firestore.dart';
import '../../../main.dart';


class SleepPage extends StatefulWidget {
  @override
  _SleepPageState createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> with SingleTickerProviderStateMixin {
  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  Color type2Color(int type) {
    if (type == 0) return Colors.yellow;
    else if (type == 1) return Colors.cyan;
    else if (type == 2) return Colors.purple;
    else if (type == 3) return Colors.green;
    return Color.fromRGBO(34, 69, 151, 1);
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
    var _renderer;
    List<charts.Series<GraphData, DateTime>> data;
      if (_daySelected) {
        _renderer = new charts.LineRendererConfig<DateTime>();
        data = sleep_dayData;
      }
      else {
        _renderer = new charts.BarRendererConfig<DateTime>(groupingType: charts.BarGroupingType.stacked);
        if (_weekSelected) data = sleep_weekdata;
        if (_monthSelected) data = sleep_monthdata;
      }

    return SingleChildScrollView(
        child: SizedBox(
          height: 275,
          child: new charts.TimeSeriesChart(
              data,
              animate: false,
              defaultRenderer: _renderer,

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
  Widget metrics(String _text, EdgeInsetsGeometry _insets, int sleepTime, int color) {
    return Row(
      children: [
        SizedBox(width: 22),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: type2Color(color),
          ),
        ),
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
        SizedBox(width: 0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          verticalDirection: VerticalDirection.up,
          children: <Widget>[
            Text((sleepTime / 60).floor().toString(), style: TextStyle(fontSize: 20.0,color: Color.fromRGBO(255, 255, 255, 0.9),)),
            Text("h", style: TextStyle(fontSize: 16.0,color: Color.fromRGBO(255, 255, 255, 0.9),),),
            SizedBox(width: 4),
            Text((sleepTime % 60).toString(), style: TextStyle(fontSize: 20.0,color: Color.fromRGBO(255, 255, 255, 0.9),)),
            Text("m", style: TextStyle(fontSize: 14.0,color: Color.fromRGBO(255, 255, 255, 0.9),),),
          ],
        ),
      ],
    );
  }
  Widget highlights() {
    if (_daySelected) {
      return Column(children: [
        metrics("Time Awake:", EdgeInsets.fromLTRB(10, 0, 109, 2.5), sleep_day_awake, 0),
        SizedBox(height: 10),
        metrics("Light Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), sleep_day_light, 1),
        SizedBox(height: 10),
        metrics("Deep Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), sleep_day_deep, 2),
        SizedBox(height: 10),
        metrics("REM Sleep:", EdgeInsets.fromLTRB(10, 0, 125, 2.5), sleep_day_rem, 3),
        SizedBox(height: 10),
        metrics("Total Time Asleep:", EdgeInsets.fromLTRB(0, 0, 69, 2.5), sleep_day_light + sleep_day_deep + sleep_day_rem, 4),
      ],);
    }
    else if (_weekSelected) {
      return Column(children: [
        metrics("Time Awake:", EdgeInsets.fromLTRB(10, 0, 109, 2.5), sleep_week_awake, 0),
        SizedBox(height: 10),
        metrics("Light Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), sleep_week_light, 1),
        SizedBox(height: 10),
        metrics("Deep Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), sleep_week_deep, 2),
        SizedBox(height: 10),
        metrics("REM Sleep:", EdgeInsets.fromLTRB(10, 0, 125, 2.5), sleep_week_rem, 3),
        SizedBox(height: 10),
        metrics("Total Time Asleep:", EdgeInsets.fromLTRB(0, 0, 69, 2.5), sleep_week_light + sleep_week_deep + sleep_week_rem, 4),
      ],);
    }
    else if (_monthSelected) {
      return Column(children: [
        metrics("Time Awake:", EdgeInsets.fromLTRB(10, 0, 109, 2.5), sleep_month_awake, 0),
        SizedBox(height: 10),
        metrics("Light Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), sleep_month_light, 1),
        SizedBox(height: 10),
        metrics("Deep Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), sleep_month_deep, 2),
        SizedBox(height: 10),
        metrics("REM Sleep:", EdgeInsets.fromLTRB(10, 0, 125, 2.5), sleep_month_rem, 3),
        SizedBox(height: 10),
        metrics("Total Time Asleep:", EdgeInsets.fromLTRB(0, 0, 69, 2.5), sleep_month_light + sleep_month_deep + sleep_month_rem, 4),
      ],);
    }
    return Text("Error");
  }



  @override
  Widget build(BuildContext context) {
    if (sleep_dayData == null) return CircularProgressIndicator();
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
                  'Sleep Time (minutes)',
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


      // region DEBUG BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          sleep_allDayData.forEach((i) {
              int s = int.parse(i.starttime.substring(0, i.starttime.length - 6));
              DateTime start = new DateTime.fromMillisecondsSinceEpoch(s);
              String start_time = "${start.hour}:${start.minute}".padLeft(5, '0');

              int e = int.parse(i.endtime.substring(0, i.endtime.length - 6));
              DateTime end = new DateTime.fromMillisecondsSinceEpoch(e);
              String end_time = "${end.hour}:${end.minute}".padLeft(5, '0');

              print("${i.type}: $start_time to $end_time");
          });


          // sleep_allDayData.forEach((i) {
          //   int s = int.parse(i.starttime.substring(0, i.starttime.length - 6));
          //   int e = int.parse(i.endtime.substring(0, i.endtime.length - 6));
          //   DateTime start = new DateTime.fromMillisecondsSinceEpoch(s);
          //   DateTime end = new DateTime.fromMillisecondsSinceEpoch(e);
          //   print("start:${start} - end:${end}");
          // });

        },
      ),
      //endregion


    );
  }
}