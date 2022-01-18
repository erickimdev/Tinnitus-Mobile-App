import 'package:intl/intl.dart';
import '../utils.dart';
import 'package:tinnitus_app/main.dart';
import '../../../FirestoreService.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';
import 'dart:io';
import "package:http/http.dart" as http;
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:random_string/random_string.dart';
import 'package:oauth2_client/src/oauth2_utils.dart';
import 'dart:math';
import 'package:intl/date_symbol_data_local.dart';


class SleepPage extends StatefulWidget {
  @override
  _SleepPageState createState() => _SleepPageState();
}

List<charts.Series<GraphData, DateTime>> dayData;
List<charts.Series<GraphData, DateTime>> weekdata;
List<charts.Series<GraphData, DateTime>> monthdata;

class _SleepPageState extends State<SleepPage> with SingleTickerProviderStateMixin {
  //region Oauth2 configuration
  String _codeVerifier;
  String _authorizationCode;
  String _accessToken;

  var flutterWebViewPlugin = FlutterWebviewPlugin();
  FlutterAppAuth _appAuth = FlutterAppAuth();
  String _clientId = '394465226852-gu85ptes9hdhtqk2i9oacs87tap58va9.apps.googleusercontent.com';
  var kAndroidUserAgent = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
  String _redirectUrl = 'http://127.0.0.1:8181';
  String _discoveryUrl = 'https://www.googleapis.com/oauth2/v1/certs';

  AuthorizationServiceConfiguration _serviceConfiguration = const AuthorizationServiceConfiguration(
      'https://accounts.google.com/o/oauth2/v2/auth',
      'https://oauth2.googleapis.com/token'
  );

  List<String> _scopes = <String>[
    'https://www.googleapis.com/auth/fitness.activity.read',
    'https://www.googleapis.com/auth/fitness.sleep.read',
    'https://www.googleapis.com/auth/fitness.heart_rate.read',
    'https://www.googleapis.com/auth/fitness.location.read'
  ];

  OAuth2Helper hlp = OAuth2Helper(GoogleOAuth2Client(
      redirectUri: 'http://127.0.0.1:8181',
      customUriScheme: 'my.test.app'),
      clientId: '394465226852-gu85ptes9hdhtqk2i9oacs87tap58va9.apps.googleusercontent.com'
  );
  //endregion


  String _highlights = "DAILY HIGHLIGHTS";
  bool _daySelected = true;
  bool _weekSelected = false;
  bool _monthSelected = false;

  // day data
    List<SleepData> allDayData = [];
    int day_awake = 0;
    int day_light = 0;
    int day_deep = 0;
    int day_rem = 0;
  // week data
    List<SleepData> allWeekData = [];
    int week_awake = 0;
    int week_light = 0;
    int week_deep = 0;
    int week_rem = 0;
  // month data
    List<SleepData> allMonthData = [];
    int month_awake = 0;
    int month_light = 0;
    int month_deep = 0;
    int month_rem = 0;


  @override
  void initState() {
    super.initState();

    if (_accessToken == null) {
      // get data
      startHttpServer();

      // authorize
      flutterWebViewPlugin.onUrlChanged.listen((String url) {
        if (mounted) setState(() { if (url.contains("code=")) flutterWebViewPlugin.close(); }); });
      startAuthorization();
    }
  }


  // 0=awake 1=light 2=deep 3=rem   OR   1=awake 2=sleep 3=outofbed 4=light 5=deep 6=rem
  charts.Color type2BarColor(int type) {
    if (type == 0) return charts.MaterialPalette.yellow.shadeDefault;
    else if (type == 1) return charts.MaterialPalette.cyan.shadeDefault;
    else if (type == 2) return charts.MaterialPalette.purple.shadeDefault;
    else if (type == 3) return charts.MaterialPalette.green.shadeDefault;
    return charts.MaterialPalette.gray.shadeDefault;
  }
  Color type2Color(int type) {
    if (type == 0) return Colors.yellow;
    else if (type == 1) return Colors.cyan;
    else if (type == 2) return Colors.purple;
    else if (type == 3) return Colors.green;
    return Color.fromRGBO(34, 69, 151, 1);
  }
  String type2String(int type) {
    if (type == 1) return "awake";
    else if (type == 2) return "sleep";
    else if (type == 3) return "out-of-bed";
    else if (type == 4) return "light sleep";
    else if (type == 5) return "deep sleep";
    else if (type == 6) return "rem sleep";
    return "no such type";
  }


  Widget timeButton(String _text, EdgeInsetsGeometry _insets, bool selected) {
    ButtonStyle buttonStyle = selected ? ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[800]))
        : ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue));
    return OutlinedButton(
        style: buttonStyle,
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
  Widget barGraph() {
    var _renderer;
    List<charts.Series<GraphData, DateTime>> data;
      if (_daySelected) {
        _renderer = new charts.LineRendererConfig<DateTime>();
        data = dayData;
      }
      else {
        _renderer = new charts.BarRendererConfig<DateTime>(groupingType: charts.BarGroupingType.stacked);
        if (_weekSelected) data = weekdata;
        if (_monthSelected) data = monthdata;
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
        metrics("Time Awake:", EdgeInsets.fromLTRB(10, 0, 109, 2.5), day_awake, 0),
        SizedBox(height: 10),
        metrics("Light Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), day_light, 1),
        SizedBox(height: 10),
        metrics("Deep Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), day_deep, 2),
        SizedBox(height: 10),
        metrics("REM Sleep:", EdgeInsets.fromLTRB(10, 0, 125, 2.5), day_rem, 3),
        SizedBox(height: 10),
        metrics("Total Time Asleep:", EdgeInsets.fromLTRB(0, 0, 69, 2.5), day_light + day_deep + day_rem, 4),
      ],);
    }
    else if (_weekSelected) {
      return Column(children: [
        metrics("Time Awake:", EdgeInsets.fromLTRB(10, 0, 109, 2.5), week_awake, 0),
        SizedBox(height: 10),
        metrics("Light Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), week_light, 1),
        SizedBox(height: 10),
        metrics("Deep Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), week_deep, 2),
        SizedBox(height: 10),
        metrics("REM Sleep:", EdgeInsets.fromLTRB(10, 0, 125, 2.5), week_rem, 3),
        SizedBox(height: 10),
        metrics("Total Time Asleep:", EdgeInsets.fromLTRB(0, 0, 69, 2.5), week_light + week_deep + week_rem, 4),
      ],);
    }
    else if (_monthSelected) {
      return Column(children: [
        metrics("Time Awake:", EdgeInsets.fromLTRB(10, 0, 109, 2.5), month_awake, 0),
        SizedBox(height: 10),
        metrics("Light Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), month_light, 1),
        SizedBox(height: 10),
        metrics("Deep Sleep:", EdgeInsets.fromLTRB(10, 0, 118, 2.5), month_deep, 2),
        SizedBox(height: 10),
        metrics("REM Sleep:", EdgeInsets.fromLTRB(10, 0, 125, 2.5), month_rem, 3),
        SizedBox(height: 10),
        metrics("Total Time Asleep:", EdgeInsets.fromLTRB(0, 0, 69, 2.5), month_light + month_deep + month_rem, 4),
      ],);
    }
    return Text("Error");
  }



  @override
  Widget build(BuildContext context) {
    if (dayData == null) return CircularProgressIndicator();
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
          // allDayData.forEach((i) {
          //   int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
          //   int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
          //   int mins = (end/60000).floor() - (start/60000).floor();
          //   String sleep_date = DateFormat("MM-dd-yyyy HH:mm").format(DateTime.fromMillisecondsSinceEpoch(start));
          //
          //   print("$sleep_date: ${i.type} - $mins minutes");
          // });

          // allMonthData.forEach((i) {
          //   int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
          //   int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
          //   int mins = (end/60000).floor() - (start/60000).floor();
          //   String sleep_date = DateFormat("MM-dd-yyyy").format(DateTime.fromMillisecondsSinceEpoch(start));
          //
          //   print("$sleep_date: ${i.type} - $mins minutes");
          // });
        },
      ),
      //endregion


    );
  }


  // DAY DATA
    List<charts.Series<GraphData, DateTime>> createDayGraph() {
      List<charts.Series<GraphData, DateTime>> final_result = [];

      var awake_map = {};
      var light_map = {};
      var deep_map = {};
      var rem_map = {};
      for (var i = 0; i <= 23; i++) awake_map[i] = 0;
      for (var i = 0; i <= 23; i++) light_map[i] = 0;
      for (var i = 0; i <= 23; i++) deep_map[i] = 0;
      for (var i = 0; i <= 23; i++) rem_map[i] = 0;

      for (var i in allDayData) {
        int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
        int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
        int mins = (end/60000).floor() - (start/60000).floor();

        DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
        DateTime sleep_date = DateTime(d.year, d.month, d.day, d.hour);

        if (i.type == "awake") {          // awake
          day_awake += mins;
          awake_map[d.hour] = awake_map[sleep_date.hour] + mins;
        }
        if (i.type == "light sleep") {    // light sleep
          day_light += mins;
          light_map[d.hour] = light_map[sleep_date.hour] + mins;
        }
        if (i.type == "deep sleep") {     // deep sleep
          day_deep += mins;
          deep_map[d.hour] = deep_map[sleep_date.hour] + mins;
        }
        if (i.type == "rem sleep") {      // rem sleep
          day_rem += mins;
          rem_map[d.hour] = rem_map[sleep_date.hour] + mins;
        }
      }

      // each value is accumulated from the previous values so that lines are constantly increasing
      List<int> range = [18,19,20,21,22,23,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
      int prev_awake = 0;
      int prev_light = 0;
      int prev_deep = 0;
      int prev_rem = 0;
      for (var i in range) {
        if (awake_map[i] != 0) {
          awake_map[i] = awake_map[i] + prev_awake;
          prev_awake = awake_map[i];
        }
        if (light_map[i] != 0) {
          light_map[i] = light_map[i] + prev_light;
          prev_light = light_map[i];
        }
        if (deep_map[i] != 0) {
          deep_map[i] = deep_map[i] + prev_deep;
          prev_deep = deep_map[i];
        }
        if (rem_map[i] != 0) {
          rem_map[i] = rem_map[i] + prev_rem;
          prev_rem = rem_map[i];
        }
      }

      List<GraphData> awake = [];
      List<GraphData> light = [];
      List<GraphData> deep = [];
      List<GraphData> rem = [];
      awake_map.forEach((k,v) {
        if (v != 0) {
          if (k >= 18) awake.add(new GraphData(DateTime(dayBegin.year, dayBegin.month, dayBegin.day-1, k), v));
          else awake.add(new GraphData(DateTime(dayEnd.year, dayEnd.month, dayEnd.day, k), v));
        }
      });
      light_map.forEach((k,v) {
        if (v != 0) {
          if (k >= 18) light.add(new GraphData(DateTime(dayBegin.year, dayBegin.month, dayBegin.day-1, k), v));
          else light.add(new GraphData(DateTime(dayEnd.year, dayEnd.month, dayEnd.day, k), v));
        }
      });
      deep_map.forEach((k,v) {
        if (v != 0) {
          if (k >= 18) deep.add(new GraphData(DateTime(dayBegin.year, dayBegin.month, dayBegin.day-1, k), v));
          else deep.add(new GraphData(DateTime(dayEnd.year, dayEnd.month, dayEnd.day, k), v));
        }
      });
      rem_map.forEach((k,v) {
        if (v != 0) {
          if (k >= 18) rem.add(new GraphData(DateTime(dayBegin.year, dayBegin.month, dayBegin.day-1, k), v));
          else rem.add(new GraphData(DateTime(dayEnd.year, dayEnd.month, dayEnd.day, k), v));
        }
      });

      List<List<GraphData>> all_data = [];
      all_data.add(awake);
      all_data.add(light);
      all_data.add(deep);
      all_data.add(rem);

      for (var i = 0; i < all_data.length; i++) {
        final_result.add(
            new charts.Series<GraphData, DateTime>(
              id: "Sleep Data",
              data: all_data[i],
              domainFn: (GraphData sleep, _) => sleep.day,      // x axis
              measureFn: (GraphData sleep, _) => sleep.value,   // y axis
              colorFn: (_, __) => type2BarColor(i),
              fillColorFn: (_, __) => type2BarColor(i),
            )
        );
      }

      return final_result;
    }
  // WEEK DATA
    List<charts.Series<GraphData, DateTime>> createWeekGraph() {
      List<charts.Series<GraphData, DateTime>> final_result = [];

      var awake_map = {};
      var light_map = {};
      var deep_map = {};
      var rem_map = {};

      List<GraphData> awake = [];
      List<GraphData> light = [];
      List<GraphData> deep = [];
      List<GraphData> rem = [];

      // entire week part of the same month
      if (firstDayOfWeek.month == lastDayOfWeek.month) {
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) awake_map[i] = 0;
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) light_map[i] = 0;
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) deep_map[i] = 0;
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) rem_map[i] = 0;

        for (var i in allWeekData) {
          int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
          int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
          int mins = (end/60000).floor() - (start/60000).floor();

          DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
          DateTime sleep_date = DateTime(d.year, d.month, d.day);

          if (i.type == "awake") {          // awake
            week_awake += mins;
            awake_map[d.day] = awake_map[sleep_date.day] + mins;
          }
          if (i.type == "light sleep") {    // light sleep
            week_light += mins;
            light_map[d.day] = light_map[sleep_date.day] + mins;
          }
          if (i.type == "deep sleep") {     // deep sleep
            week_deep += mins;
            deep_map[d.day] = deep_map[sleep_date.day] + mins;
          }
          if (i.type == "rem sleep") {      // rem sleep
            week_rem += mins;
            rem_map[d.day] = rem_map[sleep_date.day] + mins;
          }
        }

        awake_map.forEach((k,v) { awake.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), v));});
        light_map.forEach((k,v) { light.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), v)); });
        deep_map.forEach((k,v) { deep.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), v)); });
        rem_map.forEach((k,v) { rem.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), v)); });
      }
      // week merges into 2 different months
      else {
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) awake_map[i] = 0;
          for (var i = 1; i <= lastDayOfWeek.day; i++) awake_map[i] = 0;
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) light_map[i] = 0;
          for (var i = 1; i <= lastDayOfWeek.day; i++) light_map[i] = 0;
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) deep_map[i] = 0;
          for (var i = 1; i <= lastDayOfWeek.day; i++) deep_map[i] = 0;
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) rem_map[i] = 0;
          for (var i = 1; i <= lastDayOfWeek.day; i++) rem_map[i] = 0;

        for (var i in allWeekData) {
          int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
          int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
          int mins = (end/60000).floor() - (start/60000).floor();

          DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
          DateTime sleep_date = d.day > 15 ? DateTime(d.year, d.month, d.day) : DateTime(d.year, d.month+1, d.day);

          if (i.type == "awake") {          // awake
            week_awake += mins;
            awake_map[d.day] = awake_map[sleep_date.day] + mins;
          }
          if (i.type == "light sleep") {    // light sleep
            week_light += mins;
            light_map[d.day] = light_map[sleep_date.day] + mins;
          }
          if (i.type == "deep sleep") {     // deep sleep
            week_deep += mins;
            deep_map[d.day] = deep_map[sleep_date.day] + mins;
          }
          if (i.type == "rem sleep") {      // rem sleep
            week_rem += mins;
            rem_map[d.day] = rem_map[sleep_date.day] + mins;
          }
        }

        awake_map.forEach((day, sum) {
          if (day > 15) awake.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, day), sum));
          else awake.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, day), sum));
        });
        light_map.forEach((day, sum) {
          if (day > 15) light.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, day), sum));
          else light.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, day), sum));
        });
        deep_map.forEach((day, sum) {
          if (day > 15) deep.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, day), sum));
          else deep.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, day), sum));
        });
        rem_map.forEach((day, sum) {
          if (day > 15) rem.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, day), sum));
          else rem.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, day), sum));
        });
      }

      List<List<GraphData>> all_data = [];
      all_data.add(awake);
      all_data.add(light);
      all_data.add(deep);
      all_data.add(rem);

      for (var i = 0; i < all_data.length; i++) {
        final_result.add(
            new charts.Series<GraphData, DateTime>(
              id: "Sleep Data",
              data: all_data[i],
              domainFn: (GraphData sleep, _) => sleep.day,      // x axis
              measureFn: (GraphData sleep, _) => sleep.value,   // y axis
              colorFn: (_, __) => type2BarColor(i),
              fillColorFn: (_, __) => type2BarColor(i),
            )
        );
      }

      return final_result;
    }
  // MONTH DATA
    List<charts.Series<GraphData, DateTime>> createMonthGraph() {
      List<charts.Series<GraphData, DateTime>> final_result = [];

      var awake_map = {};
      var light_map = {};
      var deep_map = {};
      var rem_map = {};
      for (var i = 1; i <= lastDayOfMonth.day; i++) awake_map[i] = 0;
      for (var i = 1; i <= lastDayOfMonth.day; i++) light_map[i] = 0;
      for (var i = 1; i <= lastDayOfMonth.day; i++) deep_map[i] = 0;
      for (var i = 1; i <= lastDayOfMonth.day; i++) rem_map[i] = 0;

      for (var i in allMonthData) {
        int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
        int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
        int mins = (end/60000).floor() - (start/60000).floor();

        DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
        DateTime sleep_date = DateTime(d.year, d.month, d.day);

        if (i.type == "awake") {          // awake
          month_awake += mins;
          awake_map[d.day] = awake_map[sleep_date.day] + mins;
        }
        if (i.type == "light sleep") {    // light sleep
          month_light += mins;
          light_map[d.day] = light_map[sleep_date.day] + mins;
        }
        if (i.type == "deep sleep") {     // deep sleep
          month_deep += mins;
          deep_map[d.day] = deep_map[sleep_date.day] + mins;
        }
        if (i.type == "rem sleep") {      // rem sleep
          month_rem += mins;
          rem_map[d.day] = rem_map[sleep_date.day] + mins;
        }
      }

      List<GraphData> awake = [];
      List<GraphData> light = [];
      List<GraphData> deep = [];
      List<GraphData> rem = [];
      awake_map.forEach((k,v) { awake.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), v)); });
      light_map.forEach((k,v) { light.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), v)); });
      deep_map.forEach((k,v) { deep.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), v)); });
      rem_map.forEach((k,v) { rem.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), v)); });

      List<List<GraphData>> all_data = [];
      all_data.add(awake);
      all_data.add(light);
      all_data.add(deep);
      all_data.add(rem);

      for (var i = 0; i < all_data.length; i++) {
        final_result.add(
            new charts.Series<GraphData, DateTime>(
              id: "Sleep Data",
              data: all_data[i],
              domainFn: (GraphData sleep, _) => sleep.day,      // x axis
              measureFn: (GraphData sleep, _) => sleep.value,   // y axis
              colorFn: (_, __) => type2BarColor(i),
              fillColorFn: (_, __) => type2BarColor(i),
            )
        );
      }

      return final_result;
    }


  // HTTP PART
  Future<void> postRequest(DateTime starttime, DateTime endtime, String duration) async {
    List<Map<String, String>> _aggregate = [
      {"dataTypeName": "com.google.sleep.segment"}
    ];

    final http.Response httpResponse = await http.post(
        Uri.parse('https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate'),
        headers: <String, String>{
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "aggregateBy": _aggregate,
          "startTimeMillis": starttime.millisecondsSinceEpoch,
          "endTimeMillis": endtime.millisecondsSinceEpoch,
        })
    );

    if (httpResponse.statusCode == 200) {
      var decode = jsonDecode(httpResponse.body)['bucket'][0]['dataset'][0]['point'];
      for (var i in decode) {
        SleepData data = new SleepData(
            starttime: i['startTimeNanos'],
            endtime: i['endTimeNanos'],
            type: type2String(i['value'][0]['intVal'])
        );

        if (duration == "day") allDayData.add(data);
        if (duration == "week") allWeekData.add(data);
        if (duration == "month") allMonthData.add(data);
      }

      setState(() {});
    } else print("unable to get data");
  }
  Future<void> startHttpServer() async {
    try {
      var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8181);
      await for (var request in server) {
        if (request.headers.value('referer') != null && _authorizationCode == null) {
          var codeurl = request.headers.value('referer');
          request.response..headers.contentType = new ContentType("text", "plain", charset: "utf-8")..close();
          var codestart = codeurl.indexOf("code=");
          var codeend = codeurl.indexOf("&", codestart);
          _authorizationCode = codeurl.substring(codestart + 5, codeend);

          // deleted function
          if (_authorizationCode != null) {
            setState(() {});
            try {
              TokenResponse result = await _appAuth.token(TokenRequest(
                  _clientId, _redirectUrl,
                  authorizationCode: _authorizationCode,
                  discoveryUrl: _discoveryUrl,
                  serviceConfiguration: _serviceConfiguration,
                  codeVerifier: _codeVerifier,
                  scopes: _scopes
              ));
              _accessToken = result.accessToken;

              // send POST request to get data
              if (allDayData.isEmpty) await postRequest(dayBegin.subtract(Duration(hours: 6)), dayEnd.subtract(Duration(hours: 6)), "day");
              if (allWeekData.isEmpty) await postRequest(firstDayOfWeek, lastDayOfWeek, "week");
              if (allMonthData.isEmpty) await postRequest(firstDayOfMonth, lastDayOfMonth, "month");
              setState(() async {
                dayData = createDayGraph();
                weekdata = createWeekGraph();
                monthdata = createMonthGraph();
              });

            } catch (e) {print("error: $e");}
          }

        }
        request.response..headers.contentType = new ContentType("text", "plain", charset: "utf-8")..write("close")..close();
      }
    } catch (e) { print("server creation error: $e"); }
  }

  // AUTHORIZATION PART
  Future<void> startAuthorization() async {
    _codeVerifier ??= randomAlphaNumeric(80);
    var codeChallenge = OAuth2Utils.generateCodeChallenge(_codeVerifier);
    var auth = await hlp.client.getAuthorizeUrl(
      clientId: _clientId,
      redirectUri: _redirectUrl,
      scopes: _scopes,
      enableState: true,
      codeChallenge: codeChallenge,
    );
    try {
      flutterWebViewPlugin.launch(auth, userAgent: kAndroidUserAgent);
    } on PlatformException catch (error) {
      print("authorization error: ${error.message}");
    }
  }
}


class GraphData {
  final DateTime day;
  final int value;
  GraphData(this.day, this.value);
}

class SleepData {
  final String starttime;
  final String endtime;
  final String type;
  SleepData({this.starttime, this.endtime, this.type});
}