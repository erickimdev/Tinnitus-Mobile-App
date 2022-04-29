import '../data.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import '../../../services/firestore.dart';
import '../../../main.dart';


class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  void updateFirestore() async {
    await FirestoreService(uid: "${user.email}").activityFeatures(day, activity_day_calories, activity_day_movemins);
    await FirestoreService(uid: "${user.email}").hourlyCalories(day, firestore_calories);
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
    if (_daySelected) data = activity_dayData;
    else if (_weekSelected) data = activity_weekdata;
    else if (_monthSelected) data = activity_monthdata;

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
      return Column(children: [
        SizedBox(height: 10),
        metrics("Calories Burned:", EdgeInsets.fromLTRB(0, 0, 81, 2.5), activity_day_calories, "Kcals"),
        SizedBox(height: 10),
        metrics("Movement Minutes:", EdgeInsets.fromLTRB(0, 0, 50, 2.5), activity_day_movemins, "mins"),
      ],);
    }
    else if (_weekSelected) {
      return Column(children: [
        SizedBox(height: 10),
        metrics("Calories Burned:", EdgeInsets.fromLTRB(0, 0, 81, 2.5), activity_week_calories, "Kcals"),
        SizedBox(height: 10),
        metrics("Movement Minutes:", EdgeInsets.fromLTRB(0, 0, 50, 2.5), activity_week_movemins, "mins"),
      ],);
    }
    else if (_monthSelected) {
      return Column(children: [
        SizedBox(height: 10),
        metrics("Calories Burned:", EdgeInsets.fromLTRB(0, 0, 81, 2.5), activity_month_calories, "Kcals"),
        SizedBox(height: 10),
        metrics("Movement Minutes:", EdgeInsets.fromLTRB(0, 0, 50, 2.5), activity_month_movemins, "mins"),
      ],);
    }
    return Text("Error");
  }


  @override
  Widget build(BuildContext context) {
    if (activity_dayData == null) return CircularProgressIndicator();
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
                  'Calories Burned (calories)',
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
      //   },
      // ),
      // //endregion


    );
  }
}