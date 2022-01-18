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


class HeartPage extends StatefulWidget {
  @override
  _HeartPageState createState() => _HeartPageState();
}

List<charts.Series<GraphData, DateTime>> dayData;
List<charts.Series<GraphData, DateTime>> weekdata;
List<charts.Series<GraphData, DateTime>> monthdata;

class _HeartPageState extends State<HeartPage> with SingleTickerProviderStateMixin {
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
    List<HeartData> allDayData = [];
    List<int> day_heartrate = [];
  // week data
    List<HeartData> allWeekData = [];
    List<int> week_heartrate = [];
  // month data
    List<HeartData> allMonthData = [];
    List<int> month_heartrate = [];


  @override
  void initState() {
    super.initState();

    if (_accessToken == null) {
      // get data
      startHttpServer();

      // authorize
      flutterWebViewPlugin.onUrlChanged.listen((String url) {
        if (mounted) setState(() { if (url.contains("code=")) flutterWebViewPlugin.close(); });
      });
      startAuthorization();
    }
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
    List<charts.Series<GraphData, DateTime>> data;
    if (_daySelected) data = dayData;
    else if (_weekSelected) data = weekdata;
    else if (_monthSelected) data = monthdata;

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
      int day_avg = day_heartrate.reduce((a,b)=>a+b).toDouble() ~/ day_heartrate.length;

      return Column(children: [
        SizedBox(height: 10),
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 65, 2.5), day_heartrate.reduce(max), "BPM"),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 70, 2.5), day_heartrate.reduce(min), "BPM"),
        SizedBox(height: 10),
        metrics("Average Heart Rate:", EdgeInsets.fromLTRB(0, 0, 86, 2.5), day_avg, "BPM"),
      ],);
    }
    else if (_weekSelected) {
      int week_avg = week_heartrate.reduce((a,b)=>a+b).toDouble() ~/ week_heartrate.length;

      return Column(children: [
        SizedBox(height: 10),
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 65, 2.5), week_heartrate.reduce(max), "BPM"),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 70, 2.5), week_heartrate.reduce(min), "BPM"),
        SizedBox(height: 10),
        metrics("Average Heart Rate:", EdgeInsets.fromLTRB(0, 0, 86, 2.5), week_avg, "BPM"),
      ],);
    }
    else if (_monthSelected) {
      int month_avg = month_heartrate.reduce((a,b)=>a+b).toDouble() ~/ month_heartrate.length;

      return Column(children: [
        SizedBox(height: 10),
        metrics("Maximum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 65, 2.5), month_heartrate.reduce(max), "BPM"),
        SizedBox(height: 10),
        metrics("Minimum Heart Rate:", EdgeInsets.fromLTRB(0, 0, 70, 2.5), month_heartrate.reduce(min), "BPM"),
        SizedBox(height: 10),
        metrics("Average Heart Rate:", EdgeInsets.fromLTRB(0, 0, 86, 2.5), month_avg, "BPM"),
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
      //   },
      // ),
      // //endregion


    );
  }


  // DAY DATA
    List<charts.Series<GraphData, DateTime>> createDayGraph() {
      Map<int, List<int>> hr_map = {};
      for (var i = 0; i <= 23; i++) hr_map[i] = [];

      for (var i in allDayData) {
        DateTime hr_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        hr_map[hr_date.hour] = hr_map[hr_date.hour] + [i.bpm];

        day_heartrate.add(i.bpm);
      }

      List<GraphData> hr_list = [];
      hr_map.forEach((k,v) {
        if (v.length != 0) {
          int avg = v.reduce((a,b)=>a+b).toDouble() ~/ v.length;
          if (v != 0) hr_list.add(new GraphData(DateTime(dayEnd.year, dayEnd.month, dayEnd.day, k), avg));
        }
      });

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: hr_list,
          domainFn: (GraphData hr, _) => hr.day,      // x axis
          measureFn: (GraphData hr, _) => hr.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }
  // WEEK DATA
    List<charts.Series<GraphData, DateTime>> createWeekGraph() {
      Map<int, List<int>> hr_map = {};
      List<GraphData> hr_list = [];

      // entire week part of the same month
      if (firstDayOfWeek.month == lastDayOfWeek.month) {
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) hr_map[i] = [];

        for (var i in allWeekData) {
          DateTime hr_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          hr_map[hr_date.day] = hr_map[hr_date.day] + [i.bpm];

          week_heartrate.add(i.bpm);
        }

        hr_map.forEach((k,v) {
          if (v.length != 0) {
            int avg = v.reduce((a,b)=>a+b).toDouble() ~/ v.length;
            hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), avg));
          }
        });
      }
      // week merges into 2 different months
      else {
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) hr_map[i] = [];
        for (var i = 1; i <= lastDayOfWeek.day; i++) hr_map[i] = [];


        for (var i in allWeekData) {
          DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          DateTime sleep_date = d.day > 15 ? DateTime(d.year, d.month, d.day) : DateTime(d.year, d.month+1, d.day);
          hr_map[sleep_date.day] = hr_map[sleep_date.day] + [i.bpm];

          week_heartrate.add(i.bpm);
        }

        hr_map.forEach((k,v) {
          if (v.length != 0) {
            int avg = v.reduce((a,b)=>a+b).toDouble() ~/ v.length;
            if (k > 15) hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, k), avg));
            else hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), avg));
          }
        });
      }

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: hr_list,
          domainFn: (GraphData hr, _) => hr.day,      // x axis
          measureFn: (GraphData hr, _) => hr.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }
  // MONTH DATA
    List<charts.Series<GraphData, DateTime>> createMonthGraph() {
      Map<int, List<int>> hr_map = {};
      for (var i = 1; i <= lastDayOfMonth.day; i++) hr_map[i] = [];

      for (var i in allMonthData) {
        DateTime hr_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        hr_map[hr_date.day] = hr_map[hr_date.day] + [i.bpm];

        month_heartrate.add(i.bpm);
      }

      List<GraphData> hr_list = [];
      hr_map.forEach((k,v) {
        if (v.length != 0) {
          int avg = v.reduce((a,b)=>a+b).toDouble() ~/ v.length;
          hr_list.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), avg));
        }
      });

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: hr_list,
          domainFn: (GraphData hr, _) => hr.day,      // x axis
          measureFn: (GraphData hr, _) => hr.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }


  // HTTP PART
  Future<void> postRequest(DateTime starttime, DateTime endtime, String duration) async {
    List<Map<String, String>> _aggregate = [
      {"dataTypeName": "com.google.heart_rate.bpm"},
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
      // get heartrate data
      var heartrate = jsonDecode(httpResponse.body)['bucket'][0]['dataset'][0]['point'];
      for (var i in heartrate) {
        HeartData data = new HeartData(
            starttime: i['startTimeNanos'],
            endtime: i['endTimeNanos'],
            bpm: int.parse((i['value'][0]['fpVal']).toString())
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
              if (allDayData.isEmpty) await postRequest(dayBegin, dayEnd, "day");
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

class HeartData {
  final String starttime;
  final String endtime;
  final int bpm;
  HeartData({this.starttime, this.endtime, this.bpm});
}