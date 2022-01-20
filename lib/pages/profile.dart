import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tinnitus_app/main.dart';
import 'calendar/utils.dart';
import 'package:fit_kit/fit_kit.dart';
import 'smartwatch/utils.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:tinnitus_app/main.dart';
import 'package:tinnitus_app/pages/smartwatch/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';
import 'dart:io';
import "package:http/http.dart" as http;
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:random_string/random_string.dart';
import 'package:oauth2_client/src/oauth2_utils.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // CREATE GRAPHS
    // SLEEP
    List<charts.Series<GraphData, DateTime>> sleep_createDayGraph() {
      List<charts.Series<GraphData, DateTime>> final_result = [];

      var awake_map = {};
      var light_map = {};
      var deep_map = {};
      var rem_map = {};
      for (var i = 0; i <= 23; i++) awake_map[i] = 0;
      for (var i = 0; i <= 23; i++) light_map[i] = 0;
      for (var i = 0; i <= 23; i++) deep_map[i] = 0;
      for (var i = 0; i <= 23; i++) rem_map[i] = 0;

      for (var i in sleep_allDayData) {
        int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
        int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
        int mins = (end/60000).floor() - (start/60000).floor();

        DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
        DateTime sleep_date = DateTime(d.year, d.month, d.day, d.hour);

        if (i.type == "awake") {          // awake
          sleep_day_awake += mins;
          awake_map[d.hour] = awake_map[sleep_date.hour] + mins;
        }
        if (i.type == "light sleep") {    // light sleep
          sleep_day_light += mins;
          light_map[d.hour] = light_map[sleep_date.hour] + mins;
        }
        if (i.type == "deep sleep") {     // deep sleep
          sleep_day_deep += mins;
          deep_map[d.hour] = deep_map[sleep_date.hour] + mins;
        }
        if (i.type == "rem sleep") {      // rem sleep
          sleep_day_rem += mins;
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
    List<charts.Series<GraphData, DateTime>> sleep_createWeekGraph() {
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

        for (var i in sleep_allWeekData) {
          int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
          int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
          int mins = (end/60000).floor() - (start/60000).floor();

          DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
          DateTime sleep_date = DateTime(d.year, d.month, d.day);

          if (i.type == "awake") {          // awake
            sleep_week_awake += mins;
            awake_map[d.day] = awake_map[sleep_date.day] + mins;
          }
          if (i.type == "light sleep") {    // light sleep
            sleep_week_light += mins;
            light_map[d.day] = light_map[sleep_date.day] + mins;
          }
          if (i.type == "deep sleep") {     // deep sleep
            sleep_week_deep += mins;
            deep_map[d.day] = deep_map[sleep_date.day] + mins;
          }
          if (i.type == "rem sleep") {      // rem sleep
            sleep_week_rem += mins;
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

        for (var i in sleep_allWeekData) {
          int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
          int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
          int mins = (end/60000).floor() - (start/60000).floor();

          DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
          DateTime sleep_date = d.day > 15 ? DateTime(d.year, d.month, d.day) : DateTime(d.year, d.month+1, d.day);

          if (i.type == "awake") {          // awake
            sleep_week_awake += mins;
            awake_map[d.day] = awake_map[sleep_date.day] + mins;
          }
          if (i.type == "light sleep") {    // light sleep
            sleep_week_light += mins;
            light_map[d.day] = light_map[sleep_date.day] + mins;
          }
          if (i.type == "deep sleep") {     // deep sleep
            sleep_week_deep += mins;
            deep_map[d.day] = deep_map[sleep_date.day] + mins;
          }
          if (i.type == "rem sleep") {      // rem sleep
            sleep_week_rem += mins;
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
    List<charts.Series<GraphData, DateTime>> sleep_createMonthGraph() {
      List<charts.Series<GraphData, DateTime>> final_result = [];

      var awake_map = {};
      var light_map = {};
      var deep_map = {};
      var rem_map = {};
      for (var i = 1; i <= lastDayOfMonth.day; i++) awake_map[i] = 0;
      for (var i = 1; i <= lastDayOfMonth.day; i++) light_map[i] = 0;
      for (var i = 1; i <= lastDayOfMonth.day; i++) deep_map[i] = 0;
      for (var i = 1; i <= lastDayOfMonth.day; i++) rem_map[i] = 0;

      for (var i in sleep_allMonthData) {
        int start = int.parse(i.starttime.substring(0, i.starttime.length - 6));
        int end = int.parse(i.endtime.substring(0, i.endtime.length - 6));
        int mins = (end/60000).floor() - (start/60000).floor();

        DateTime d = new DateTime.fromMillisecondsSinceEpoch(start);
        DateTime sleep_date = DateTime(d.year, d.month, d.day);

        if (i.type == "awake") {          // awake
          sleep_month_awake += mins;
          awake_map[d.day] = awake_map[sleep_date.day] + mins;
        }
        if (i.type == "light sleep") {    // light sleep
          sleep_month_light += mins;
          light_map[d.day] = light_map[sleep_date.day] + mins;
        }
        if (i.type == "deep sleep") {     // deep sleep
          sleep_month_deep += mins;
          deep_map[d.day] = deep_map[sleep_date.day] + mins;
        }
        if (i.type == "rem sleep") {      // rem sleep
          sleep_month_rem += mins;
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
    // HEART
    List<charts.Series<GraphData, DateTime>> heart_createDayGraph() {
      Map<int, List<int>> hr_map = {};
      for (var i = 0; i <= 23; i++) hr_map[i] = [];

      for (var i in heart_allDayData) {
        DateTime hr_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        hr_map[hr_date.hour] = hr_map[hr_date.hour] + [i.bpm];

        heart_day_heartrate.add(i.bpm);
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
    List<charts.Series<GraphData, DateTime>> heart_createWeekGraph() {
      Map<int, List<int>> hr_map = {};
      List<GraphData> hr_list = [];

      // entire week part of the same month
      if (firstDayOfWeek.month == lastDayOfWeek.month) {
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) hr_map[i] = [];

        for (var i in heart_allWeekData) {
          DateTime hr_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          hr_map[hr_date.day] = hr_map[hr_date.day] + [i.bpm];

          heart_week_heartrate.add(i.bpm);
        }

        hr_map.forEach((k,v) {
          if (v.length != 0) {
            int avg = v.reduce((a,b)=>a+b).toDouble() ~/ v.length;
            hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), avg));
          }
          else hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), 0));
        });
      }
      // week merges into 2 different months
      else {
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) hr_map[i] = [];
        for (var i = 1; i <= lastDayOfWeek.day; i++) hr_map[i] = [];

        for (var i in heart_allWeekData) {
          DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          DateTime sleep_date = d.day > 15 ? DateTime(d.year, d.month, d.day) : DateTime(d.year, d.month+1, d.day);
          hr_map[sleep_date.day] = hr_map[sleep_date.day] + [i.bpm];

          heart_week_heartrate.add(i.bpm);
        }

        hr_map.forEach((k,v) {
          if (v.length != 0) {
            int avg = v.reduce((a,b)=>a+b).toDouble() ~/ v.length;
            if (k > 15) hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, k), avg));
            else hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), avg));
          }
          else {
            if (k > 15) hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, k), 0));
            else hr_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), 0));

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
    List<charts.Series<GraphData, DateTime>> heart_createMonthGraph() {
      Map<int, List<int>> hr_map = {};
      for (var i = 1; i <= lastDayOfMonth.day; i++) hr_map[i] = [];

      for (var i in heart_allMonthData) {
        DateTime hr_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        hr_map[hr_date.day] = hr_map[hr_date.day] + [i.bpm];

        heart_month_heartrate.add(i.bpm);
      }

      List<GraphData> hr_list = [];
      hr_map.forEach((k,v) {
        if (v.length != 0) {
          int avg = v.reduce((a,b)=>a+b).toDouble() ~/ v.length;
          hr_list.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), avg));
        }
        else hr_list.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), 0));
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
    // ACTIVITY
    List<charts.Series<GraphData, DateTime>> activity_createDayGraph() {
      var burned_map = {};
      for (var i = 0; i <= 23; i++) burned_map[i] = 0;

      for (var i in activity_allDayData) {
        DateTime burned_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        burned_map[burned_date.hour] = burned_map[burned_date.hour] + i.burned;

        activity_day_calories += i.burned;
      }

      // each value is accumulated from the previous values so that lines are constantly increasing
      List<int> range = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];
      int prev_awake = 0;
      for (var i in range) {
        if (burned_map[i] != 0) {
          burned_map[i] = burned_map[i] + prev_awake;
          prev_awake = burned_map[i];
        }
      }

      List<GraphData> burned_list = [];
      burned_map.forEach((k,v) {
        if (v != 0) burned_list.add(new GraphData(DateTime(dayEnd.year, dayEnd.month, dayEnd.day, k), v));
      });

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: burned_list,
          domainFn: (GraphData burned, _) => burned.day,      // x axis
          measureFn: (GraphData burned, _) => burned.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }
    List<charts.Series<GraphData, DateTime>> activity_createWeekGraph() {
      var burned_map = {};
      List<GraphData> burneds_list = [];

      // entire week part of the same month
      if (firstDayOfWeek.month == lastDayOfWeek.month) {
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) burned_map[i] = 0;

        for (var i in activity_allWeekData) {
          DateTime burned_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          burned_map[burned_date.day] = burned_map[burned_date.day] + i.burned;

          activity_week_calories += i.burned;
        }

        burned_map.forEach((k,v) { burneds_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), v));});
      }
      // week merges into 2 different months
      else {
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) burned_map[i] = 0;
        for (var i = 1; i <= lastDayOfWeek.day; i++) burned_map[i] = 0;


        for (var i in activity_allWeekData) {
          DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          DateTime sleep_date = d.day > 15 ? DateTime(d.year, d.month, d.day) : DateTime(d.year, d.month+1, d.day);
          burned_map[sleep_date.day] = burned_map[sleep_date.day] + i.burned;

          activity_week_calories += i.burned;
        }

        burned_map.forEach((day, sum) {
          if (day > 15) burneds_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, day), sum));
          else burneds_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, day), sum));
        });
      }

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: burneds_list,
          domainFn: (GraphData burned, _) => burned.day,      // x axis
          measureFn: (GraphData burned, _) => burned.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }
    List<charts.Series<GraphData, DateTime>> activity_createMonthGraph() {
      var burned_map = {};
      for (var i = 1; i <= lastDayOfMonth.day; i++) burned_map[i] = 0;

      for (var i in activity_allMonthData) {
        DateTime burned_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        burned_map[burned_date.day] = burned_map[burned_date.day] + i.burned;

        activity_month_calories += i.burned;
      }

      List<GraphData> burned_list = [];
      burned_map.forEach((k,v) { burned_list.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), v)); });

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: burned_list,
          domainFn: (GraphData burned, _) => burned.day,      // x axis
          measureFn: (GraphData burned, _) => burned.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }
    // STEPS
    List<charts.Series<GraphData, DateTime>> steps_createDayGraph() {
      var step_map = {};
      for (var i = 0; i <= 23; i++) step_map[i] = 0;

      for (var i in steps_allDayData) {
        DateTime step_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        step_map[step_date.hour] = step_map[step_date.hour] + i.steps;

        steps_day_steps += i.steps;
      }

      // each value is accumulated from the previous values so that lines are constantly increasing
      List<int> range = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];
      int prev_awake = 0;
      for (var i in range) {
        if (step_map[i] != 0) {
          step_map[i] = step_map[i] + prev_awake;
          prev_awake = step_map[i];
        }
      }

      List<GraphData> step_list = [];
      step_map.forEach((k,v) {
        if (v != 0) step_list.add(new GraphData(DateTime(dayEnd.year, dayEnd.month, dayEnd.day, k), v));
      });

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: step_list,
          domainFn: (GraphData step, _) => step.day,      // x axis
          measureFn: (GraphData step, _) => step.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }
    List<charts.Series<GraphData, DateTime>> steps_createWeekGraph() {
      var step_map = {};
      List<GraphData> steps_list = [];

      // entire week part of the same month
      if (firstDayOfWeek.month == lastDayOfWeek.month) {
        for (var i = firstDayOfWeek.day; i <= lastDayOfWeek.day; i++) step_map[i] = 0;

        for (var i in steps_allWeekData) {
          DateTime step_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          step_map[step_date.day] = step_map[step_date.day] + i.steps;

          steps_week_steps += i.steps;
        }

        step_map.forEach((k,v) { steps_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, k), v));});
      }
      // week merges into 2 different months
      else {
        for (var i = firstDayOfWeek.day; i <= DateTime(firstDayOfWeek.year, firstDayOfWeek.month + 1, 0).day; i++) step_map[i] = 0;
        for (var i = 1; i <= lastDayOfWeek.day; i++) step_map[i] = 0;


        for (var i in steps_allWeekData) {
          DateTime d = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
          DateTime sleep_date = d.day > 15 ? DateTime(d.year, d.month, d.day) : DateTime(d.year, d.month+1, d.day);
          step_map[sleep_date.day] = step_map[sleep_date.day] + i.steps;

          steps_week_steps += i.steps;
        }

        step_map.forEach((day, sum) {
          if (day > 15) steps_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month-1, day), sum));
          else steps_list.add(new GraphData(DateTime(lastDayOfWeek.year, lastDayOfWeek.month, day), sum));
        });
      }

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: steps_list,
          domainFn: (GraphData step, _) => step.day,      // x axis
          measureFn: (GraphData step, _) => step.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }
    List<charts.Series<GraphData, DateTime>> steps_createMonthGraph() {
      var step_map = {};
      for (var i = 1; i <= lastDayOfMonth.day; i++) step_map[i] = 0;

      for (var i in steps_allMonthData) {
        DateTime step_date = new DateTime.fromMillisecondsSinceEpoch(int.parse(i.starttime.substring(0, i.starttime.length - 6)));
        step_map[step_date.day] = step_map[step_date.day] + i.steps;

        steps_month_steps += i.steps;
      }

      List<GraphData> step_list = [];
      step_map.forEach((k,v) { step_list.add(new GraphData(DateTime(lastDayOfMonth.year, lastDayOfMonth.month, k), v)); });

      List<charts.Series<GraphData, DateTime>> final_result = [
        new charts.Series<GraphData, DateTime>(
          id: "Sleep Data",
          data: step_list,
          domainFn: (GraphData step, _) => step.day,      // x axis
          measureFn: (GraphData step, _) => step.value,   // y axis
          colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
          fillColorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        )
      ];

      return final_result;
    }


  // HTTP PART
  Future<void> postRequest(DateTime starttime, DateTime endtime, String duration) async {
    // POST request for sleep - requires 6 hours offset
      List<Map<String, String>> _aggregate_sleep = [
        // sleep
        {"dataTypeName": "com.google.sleep.segment"},       // 0
      ];

      final http.Response httpResponse_sleep = await http.post(
          Uri.parse('https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate'),
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "aggregateBy": _aggregate_sleep,
            "startTimeMillis": starttime.subtract(Duration(hours: 6)).millisecondsSinceEpoch,
            "endTimeMillis": endtime.subtract(Duration(hours: 6)).millisecondsSinceEpoch,
          })
      );

      if (httpResponse_sleep.statusCode == 200) {
        // region sleep
        var sleep = jsonDecode(httpResponse_sleep.body)['bucket'][0]['dataset'][0]['point'];
        for (var i in sleep) {
          SleepData data = new SleepData(
              starttime: i['startTimeNanos'],
              endtime: i['endTimeNanos'],
              type: type2String(i['value'][0]['intVal'])
          );

          if (duration == "day") sleep_allDayData.add(data);
          if (duration == "week") sleep_allWeekData.add(data);
          if (duration == "month") sleep_allMonthData.add(data);
        }
        //endregion
      }


    // POST request for heart, activity, steps
      List<Map<String, String>> _aggregate = [
        // heart
        {"dataTypeName": "com.google.heart_rate.bpm"},      // 0
        // activity
        {"dataTypeName": "com.google.calories.expended"},   // 1
        {"dataTypeName": "com.google.active_minutes"},      // 2
        // steps
        {"dataTypeName": "com.google.step_count.delta"},    // 3
        {"dataTypeName": "com.google.distance.delta"},      // 4
      ];

      final http.Response httpResponse = await http.post(
          Uri.parse('https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate'),
          headers: <String, String>{
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "aggregateBy": _aggregate,
            "startTimeMillis": starttime.millisecondsSinceEpoch,
            "endTimeMillis": endtime.millisecondsSinceEpoch,
          })
      );

      if (httpResponse.statusCode == 200) {
        // region heart
        var heartrate = jsonDecode(httpResponse.body)['bucket'][0]['dataset'][0]['point'];
        for (var i in heartrate) {
          HeartData data = new HeartData(
              starttime: i['startTimeNanos'],
              endtime: i['endTimeNanos'],
              bpm: int.parse((i['value'][0]['fpVal']).toString())
          );

          if (duration == "day") heart_allDayData.add(data);
          if (duration == "week") heart_allWeekData.add(data);
          if (duration == "month") heart_allMonthData.add(data);
        }
        //endregion

        // region activity
        // get calories burned data
        var calories_burned = jsonDecode(httpResponse.body)['bucket'][0]['dataset'][1]['point'];
        for (var i in calories_burned) {
          CalorieData data = new CalorieData(
              starttime: i['startTimeNanos'],
              endtime: i['endTimeNanos'],
              burned: int.parse(double.parse((i['value'][0]['fpVal']).toString()).floor().toString())
          );

          if (duration == "day") activity_allDayData.add(data);
          if (duration == "week") activity_allWeekData.add(data);
          if (duration == "month") activity_allMonthData.add(data);
        }

        // get movement minutes data
        var move_mins = jsonDecode(httpResponse.body)['bucket'][0]['dataset'][2]['point'];
        for (var i in move_mins) {
          int mins = int.parse((i['value'][0]['intVal']).toString());

          if (duration == "day") activity_day_movemins += mins;
          if (duration == "week") activity_week_movemins += mins;
          if (duration == "month") activity_month_movemins += mins;
        }
        // endregion

        // region steps
        // get step count data
        var step_count = jsonDecode(httpResponse.body)['bucket'][0]['dataset'][3]['point'];
        for (var i in step_count) {
          StepData data = new StepData(
              starttime: i['startTimeNanos'],
              endtime: i['endTimeNanos'],
              steps: int.parse((i['value'][0]['intVal']).toString())
          );

          if (duration == "day") steps_allDayData.add(data);
          if (duration == "week") steps_allWeekData.add(data);
          if (duration == "month") steps_allMonthData.add(data);
        }

        // get distance data
        var distance = jsonDecode(httpResponse.body)['bucket'][0]['dataset'][4]['point'];
        for (var i in distance) {
          int distance = int.parse(double.parse((i['value'][0]['fpVal']).toString()).floor().toString());

          if (duration == "day") steps_day_distance += distance;
          if (duration == "week") steps_week_distance += distance;
          if (duration == "month") steps_month_distance += distance;
        }
        // endregion

        setState(() {});
      }
  }
  Future<void> startHttpServer() async {
    try {
      var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8181);
      await for (var request in server) {
        if (request.headers.value('referer') != null && authorizationCode == null) {
          var codeurl = request.headers.value('referer');
          request.response..headers.contentType = new ContentType("text", "plain", charset: "utf-8")..close();
          var codestart = codeurl.indexOf("code=");
          var codeend = codeurl.indexOf("&", codestart);
          authorizationCode = codeurl.substring(codestart + 5, codeend);

          // deleted function
          if (authorizationCode != null) {
            setState(() {});
            try {
              TokenResponse result = await appAuth.token(TokenRequest(
                  clientId, redirectUrl,
                  authorizationCode: authorizationCode,
                  discoveryUrl: discoveryUrl,
                  serviceConfiguration: serviceConfiguration,
                  codeVerifier: codeVerifier,
                  scopes: scopes
              ));
              accessToken = result.accessToken;

              // send POST request to get data - note sleep_allXData can be any of the 4 just make sure DS is empty
              if (sleep_allDayData.isEmpty) await postRequest(dayBegin, dayEnd, "day");
              if (sleep_allWeekData.isEmpty) await postRequest(firstDayOfWeek, lastDayOfWeek, "week");
              if (sleep_allMonthData.isEmpty) await postRequest(firstDayOfMonth, lastDayOfMonth, "month");

              setState(() async {
                // SLEEP
                sleep_dayData = sleep_createDayGraph();
                sleep_weekdata = sleep_createWeekGraph();
                sleep_monthdata = sleep_createMonthGraph();
                // HEART
                heart_dayData = heart_createDayGraph();
                heart_weekdata = heart_createWeekGraph();
                heart_monthdata = heart_createMonthGraph();
                // ACTIVITY
                activity_dayData = activity_createDayGraph();
                activity_weekdata = activity_createWeekGraph();
                activity_monthdata = activity_createMonthGraph();
                // STEPS
                steps_dayData = steps_createDayGraph();
                steps_weekdata = steps_createWeekGraph();
                steps_monthdata = steps_createMonthGraph();
              });

            } catch (e) {print("error: $e");}
          }

        }
        request.response..headers.contentType = new ContentType("text", "plain", charset: "utf-8")..write("close")..close();
      }
    } catch (e) { print("server creation error: $e"); }

    Navigator.pop(context);
  }

  // AUTHORIZATION PART
  Future<void> startAuthorization() async {
    codeVerifier ??= randomAlphaNumeric(80);
    var codeChallenge = OAuth2Utils.generateCodeChallenge(codeVerifier);
    var auth = await hlp.client.getAuthorizeUrl(
      clientId: clientId,
      redirectUri: redirectUrl,
      scopes: scopes,
      enableState: true,
      codeChallenge: codeChallenge,
    );
    try {
      flutterWebViewPlugin.launch(auth, userAgent: kAndroidUserAgent);
    } on PlatformException catch (error) {
      print("authorization error: ${error.message}");
    }
  }



  @override
  void initState() {
    super.initState();

    if (!loggedIn) {
      // POST REQUEST GOOGLE LOGIN
      if (accessToken == null) {
        // get data
        startHttpServer();

        // authorize
        flutterWebViewPlugin.onUrlChanged.listen((String url) {
          if (mounted) setState(() { if (url.contains("code=")) flutterWebViewPlugin.close(); }); });
        startAuthorization();
      }

      loggedIn = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Text('Loading...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
      ),

    );
  }
}