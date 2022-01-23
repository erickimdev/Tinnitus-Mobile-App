import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/google_oauth2_client.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

// "current" date to read data
  DateTime d = DateTime(2022, 1, 19);
  // DateTime d = DateTime.now();
  DateTime day = DateTime(d.year, d.month, d.day);

// time units for what range of data to read
  DateTime dayBegin = new DateTime(day.year, day.month, day.day);
  DateTime dayEnd = new DateTime(day.year, day.month, day.day, 23, 59, 59);
  DateTime firstDayOfWeek = day.subtract(Duration(days: day.weekday % 7));
  DateTime lastDayOfWeek = day.subtract(Duration(days: day.weekday % 7)).add(Duration(days: 7)).subtract(Duration(minutes: 1));
  DateTime firstDayOfMonth = new DateTime(day.year, day.month, 1);
  DateTime lastDayOfMonth = new DateTime(day.year, day.month, DateTime(day.year, day.month + 1, 0).day, 23, 59, 59);

//region Oauth2 configuration
  String codeVerifier;
  String authorizationCode;
  String accessToken;

  var flutterWebViewPlugin = FlutterWebviewPlugin();
  FlutterAppAuth appAuth = FlutterAppAuth();
  String clientId = '394465226852-gu85ptes9hdhtqk2i9oacs87tap58va9.apps.googleusercontent.com';
  String kAndroidUserAgent = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
  String redirectUrl = 'http://127.0.0.1:8181';
  String discoveryUrl = 'https://www.googleapis.com/oauth2/v1/certs';

  AuthorizationServiceConfiguration serviceConfiguration = const AuthorizationServiceConfiguration(
      'https://accounts.google.com/o/oauth2/v2/auth',
      'https://oauth2.googleapis.com/token'
  );

  List<String> scopes = <String>[
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


// 0=awake 1=light 2=deep 3=rem   OR   1=awake 2=sleep 3=outofbed 4=light 5=deep 6=rem
charts.Color type2BarColor(int type) {
  if (type == 0) return charts.MaterialPalette.yellow.shadeDefault;
  else if (type == 1) return charts.MaterialPalette.cyan.shadeDefault;
  else if (type == 2) return charts.MaterialPalette.purple.shadeDefault;
  else if (type == 3) return charts.MaterialPalette.green.shadeDefault;
  return charts.MaterialPalette.gray.shadeDefault;
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


class GraphData {
  final DateTime day;
  final int value;
  GraphData(this.day, this.value);
}

// region SLEEP DATA
  class SleepData {
    final String starttime;
    final String endtime;
    final String type;
    SleepData({this.starttime, this.endtime, this.type});
  }

  List<charts.Series<GraphData, DateTime>> sleep_dayData;
  List<charts.Series<GraphData, DateTime>> sleep_weekdata;
  List<charts.Series<GraphData, DateTime>> sleep_monthdata;

  // day data
    List<SleepData> sleep_allDayData = [];
    int sleep_day_awake = 0;
    int sleep_day_light = 0;
    int sleep_day_deep = 0;
    int sleep_day_rem = 0;
  // week data
    List<SleepData> sleep_allWeekData = [];
    int sleep_week_awake = 0;
    int sleep_week_light = 0;
    int sleep_week_deep = 0;
    int sleep_week_rem = 0;
  // month data
    List<SleepData> sleep_allMonthData = [];
    int sleep_month_awake = 0;
    int sleep_month_light = 0;
    int sleep_month_deep = 0;
    int sleep_month_rem = 0;
// endregion

// region HEART DATA
  class HeartData {
    final String starttime;
    final String endtime;
    final int bpm;
    HeartData({this.starttime, this.endtime, this.bpm});
  }

  List<charts.Series<GraphData, DateTime>> heart_dayData;
  List<charts.Series<GraphData, DateTime>> heart_weekdata;
  List<charts.Series<GraphData, DateTime>> heart_monthdata;

  // day data
    List<HeartData> heart_allDayData = [];
    List<int> heart_day_heartrate = [];
  // week data
    List<HeartData> heart_allWeekData = [];
    List<int> heart_week_heartrate = [];
  // month data
    List<HeartData> heart_allMonthData = [];
    List<int> heart_month_heartrate = [];
// endregion

// region ACTIVITY DATA
  class CalorieData {
    final String starttime;
    final String endtime;
    final int burned;
    CalorieData({this.starttime, this.endtime, this.burned});
  }

  List<charts.Series<GraphData, DateTime>> activity_dayData;
  List<charts.Series<GraphData, DateTime>> activity_weekdata;
  List<charts.Series<GraphData, DateTime>> activity_monthdata;

  // day data
    List<CalorieData> activity_allDayData = [];
    int activity_day_calories = 0;
    int activity_day_movemins = 0;
  // week data
    List<CalorieData> activity_allWeekData = [];
    int activity_week_calories = 0;
    int activity_week_movemins = 0;
  // month data
    List<CalorieData> activity_allMonthData = [];
    int activity_month_calories = 0;
    int activity_month_movemins = 0;
// endregion

// region STEPS DATA
  class StepData {
    final String starttime;
    final String endtime;
    final int steps;
    StepData({this.starttime, this.endtime, this.steps});
  }

  List<charts.Series<GraphData, DateTime>> steps_dayData;
  List<charts.Series<GraphData, DateTime>> steps_weekdata;
  List<charts.Series<GraphData, DateTime>> steps_monthdata;

  // day data
    List<StepData> steps_allDayData = [];
    int steps_day_steps = 0;
    int steps_day_distance = 0;
  // week data
    List<StepData> steps_allWeekData = [];
    int steps_week_steps = 0;
    int steps_week_distance = 0;
  // month data
    List<StepData> steps_allMonthData = [];
    int steps_month_steps = 0;
    int steps_month_distance = 0;
// endregion