import 'package:charts_flutter/flutter.dart';
import 'package:health/health.dart';
import 'package:tinnitus_app/pages/smartwatch/parts/step.dart';
import '../../FirestoreService.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../main.dart';
import 'smartwatch.dart';

HealthFactory health = HealthFactory();

// "current" date to read data
  DateTime d = DateTime(2021, 9, 15);
  // DateTime d = DateTime.now();
  DateTime day = DateTime(d.year, d.month, d.day);

// time units for what range of data to read
  DateTime dayBegin = new DateTime(day.year, day.month, day.day);
  DateTime dayEnd = new DateTime(day.year, day.month, day.day, 23, 59, 59);
  DateTime firstDayOfWeek = day.subtract(Duration(days: day.weekday % 7));
  DateTime lastDayOfWeek = day.subtract(Duration(days: day.weekday % 7)).add(Duration(days: 7)).subtract(Duration(minutes: 1));
  DateTime firstDayOfMonth = new DateTime(day.year, day.month, 1);
  DateTime lastDayOfMonth = new DateTime(day.year, day.month, DateTime(day.year, day.month + 1, 0).day, 23, 59, 59);

















// FIRESTORE
String uid = user.email;
List<HealthDataType> types = [
    // HEART
  HealthDataType.HEART_RATE,
  // HealthDataType.RESTING_HEART_RATE,   // NOT AVAILABLE ON ANDROID
  // HealthDataType.WALKING_HEART_RATE,   // NOT AVAILABLE ON ANDROID

    // STEP
  HealthDataType.STEPS,
  HealthDataType.DISTANCE_DELTA,

    // ACTIVITY
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.MOVE_MINUTES,

    // SLEEP
  // HealthDataType.SLEEP_ASLEEP,     // NOT AVAILABLE ON ANDROID
  // HealthDataType.SLEEP_AWAKE,      // NOT AVAILABLE ON ANDROID
  // HealthDataType.SLEEP_IN_BED,     // NOT AVAILABLE ON ANDROID
];

// FIRESTORE HEART
Future firestoreHeart(DateTime _day, Map<int, List<int>> heartratesMap, List<int> heartrates,List<int> heartratesResting, List<int> heartratesWalking) async {
  // FEATURES
  int avgHR = heartrates.reduce((a,b) => a+b).toDouble() ~/ heartrates.length;
  int avgRestingHR = heartratesResting.reduce((a,b) => a+b).toDouble() ~/ heartratesResting.length;
  int avgWalkingHR = heartratesWalking.reduce((a,b) => a+b).toDouble() ~/ heartratesWalking.length;
  int maxHR = heartrates.reduce(max);
  int minHR = heartrates.reduce(min);
  await FirestoreService(uid: uid).heartFeatures(_day, avgHR, avgRestingHR, avgWalkingHR, maxHR, minHR);

  // HOURLY HEART RATE
  Map<String, int> hourlyHRs = {};
  heartratesMap.forEach((k, v) {
    String time = DateFormat('HH:mm').format(DateTime(_day.year, _day.month, _day.day, k)).toString();
    int avg = v.reduce((a,b) => a+b).toDouble() ~/ v.length;
    hourlyHRs.addAll({time: avg});
  });
  await FirestoreService(uid: uid).hourlyHeartRate(_day, hourlyHRs);
}

// FIRESTORE STEP
Future firestoreStep(DateTime _day, int totalSteps, int totalDistance, Map<int, List<int>> stepsMap, Map<int, List<int>> distanceMap) async {
  // FEATURES
  int steps = totalSteps;
  int distance = totalDistance;
  await FirestoreService(uid: uid).stepFeatures(_day, steps, distance);

  // HOURLY STEP RATE
  int accSteps = 0;
  Map<String, int> hourlySteps = {};
  stepsMap.forEach((k, v) {
    String time = DateFormat('HH:mm').format(DateTime(_day.year, _day.month, _day.day, k)).toString();
    accSteps += v.reduce((a,b) => a+b);
    hourlySteps.addAll({time: accSteps});
  });
  await FirestoreService(uid: uid).hourlySteps(_day, hourlySteps);

  // HOURLY DISTANCE
  int accDistance = 0;
  Map<String, int> hourlyDistance = {};
  distanceMap.forEach((k, v) {
    String time = DateFormat('HH:mm').format(DateTime(_day.year, _day.month, _day.day, k)).toString();
    accDistance += v.reduce((a,b) => a+b);
    hourlyDistance.addAll({time: accDistance});
  });
  await FirestoreService(uid: uid).hourlyDistance(_day, hourlyDistance);
}

// FIRESTORE ACTIVITY
Future firestoreActivity(DateTime _day, int energyBurned, int movementMins, Map<int, List<int>> energyBurnedMap, Map<int, List<int>> moveMinsMap) async {
  // FEATURES
  int burned = energyBurned;
  int MM = movementMins;
  await FirestoreService(uid: uid).activityFeatures(_day, burned, MM);

  // HOURLY CALORIES BURNED
  int accBurned = 0;
  Map<String, int> hourlyBurned = {};
  energyBurnedMap.forEach((k, v) {
    if (v.isNotEmpty) {
      String time = DateFormat('HH:mm').format(DateTime(_day.year, _day.month, _day.day, k)).toString();
      accBurned += v.reduce((a,b) => a+b);
      hourlyBurned.addAll({time: accBurned});
    }
  });
  await FirestoreService(uid: uid).hourlyCalories(_day, hourlyBurned);

  // HOURLY MOVEMENT MINUTES
  int accMM = 0;
  Map<String, int> hourlyMM = {};
  moveMinsMap.forEach((k, v) {
    String time = DateFormat('HH:mm').format(DateTime(_day.year, _day.month, _day.day, k)).toString();
    accMM += v.reduce((a,b) => a+b);
    hourlyMM.addAll({time: accMM});
  });
  await FirestoreService(uid: uid).hourlyMovementMins(_day, hourlyMM);
}

// FIRESTORE SLEEP
Future firestoreSleep(DateTime _day, List<int> sleepTime, List<int> awakeTime, List<int> inBedTime) async {
  // FEATURES
  int asleep = sleepTime.reduce((a,b) => a+b);
  int awake = awakeTime.reduce((a,b) => a+b);
  int inBed = inBedTime.reduce((a,b) => a+b);
  await FirestoreService(uid: uid).sleepFeatures(day, asleep, awake, inBed);
}

// GET DATA - month and day
bool uploaded = false;
Future<void> gatherData(int start, int end) async {
  uploaded = true;
  uploading = true;
  for (int i = start; i < end; i++) {
    // current day to read => goes from beginning to end of month
    DateTime dayBegin = firstDayOfMonth.subtract(Duration(days: 1)).add(Duration(days: i));
    DateTime dayEnd = new DateTime(dayBegin.year, dayBegin.month, dayBegin.day, 23, 59, 59);


    // data structures
    List<HealthDataPoint> dataDay = [];
    // heart
    Map<int, List<int>> heartratesMap = {};
    List<int> heartrates = [];
    List<int> heartratesWalking = [];
    List<int> heartratesResting = [];
    // step
    int totalSteps = 0;
    int totalDistance = 0;
    Map<int, List<int>> stepsMap = {};
    Map<int, List<int>> distanceMap = {};
    // activity
    int energyBurned = 0;
    int movementMins = 0;
    Map<int, List<int>> energyBurnedMap = {};
    Map<int, List<int>> moveMinsMap = {};
    // sleep
    List<int> sleepTime = [];
    List<int> awakeTime = [];
    List<int> inBedTime = [];


    // READ data using healthkit
    List<HealthDataPoint> healthDataDay = await health.getHealthDataFromTypes(dayBegin, dayEnd, types);
    dataDay.addAll(healthDataDay);
    // WRITE data into data structures
    for (var i = 0; i < dataDay.length; i++) {
      DateTime date = dataDay[i].dateTo;
      int value = dataDay[i].value.floor();

      // HEART
      if (dataDay[i].type == HealthDataType.WALKING_HEART_RATE) heartratesWalking.add(value);
      if (dataDay[i].type == HealthDataType.RESTING_HEART_RATE) heartratesResting.add(value);
      if (dataDay[i].type == HealthDataType.HEART_RATE) {
        heartrates.add(value);
        if (!heartratesMap.containsKey(date.hour)) heartratesMap[date.hour] = [];
        heartratesMap[date.hour] = heartratesMap[date.hour]..addAll([value]);
      }

      // STEP
      if (dataDay[i].type == HealthDataType.STEPS) {
        totalSteps += value;
        if (!stepsMap.containsKey(date.hour)) stepsMap[date.hour] = [];
        stepsMap[date.hour] = stepsMap[date.hour]..addAll([value]);
      }
      if (dataDay[i].type == HealthDataType.DISTANCE_DELTA) {
        totalDistance += value;
        if (!distanceMap.containsKey(date.hour)) distanceMap[date.hour] = [];
        distanceMap[date.hour] = distanceMap[date.hour]..addAll([value]);
      }

      // ACTIVITY
      if (dataDay[i].type == HealthDataType.ACTIVE_ENERGY_BURNED) {
        if ((dataDay[i].value - dataDay[i].value.floor()).abs() == 0) {
          if (!energyBurnedMap.containsKey(date.hour)) energyBurnedMap[date.hour] = [];
          energyBurnedMap[date.hour] = energyBurnedMap[date.hour]..addAll([value]);
          energyBurned += value;
        }
      }
      if (dataDay[i].type == HealthDataType.MOVE_MINUTES) {
        movementMins += value;
        if (!moveMinsMap.containsKey(date.hour)) moveMinsMap[date.hour] = [];
        moveMinsMap[date.hour] = moveMinsMap[date.hour]..addAll([value]);
      }

      // SLEEP
      if (dataDay[i].type == HealthDataType.SLEEP_ASLEEP) sleepTime.add(value);
      if (dataDay[i].type == HealthDataType.SLEEP_AWAKE) awakeTime.add(value);
      if (dataDay[i].type == HealthDataType.SLEEP_IN_BED) inBedTime.add(value);
    }


    // add empty data structures (to avoid empty list errors)
    // heart
    if (heartrates.isEmpty) heartrates.add(0);
    if (heartratesWalking.isEmpty) heartratesWalking.add(0);
    if (heartratesResting.isEmpty) heartratesResting.add(0);
    // sleep
    if (sleepTime.isEmpty) sleepTime.add(0);
    if (awakeTime.isEmpty) awakeTime.add(0);
    if (inBedTime.isEmpty) inBedTime.add(0);


    // save month's data into firestore
    // heart
    if (heartrates.reduce((a,b) => a+b) != 0)
      await firestoreHeart(dayBegin, heartratesMap, heartrates, heartratesResting, heartratesWalking);
    // step
    if (totalSteps != 0 && totalDistance != 0)
      await firestoreStep(dayBegin, totalSteps, totalDistance, stepsMap, distanceMap);
    // activity
    if (energyBurned != 0 && movementMins != 0)
      await firestoreActivity(dayBegin, energyBurned, movementMins, energyBurnedMap, moveMinsMap);
    // sleep
    if (sleepTime.reduce((a,b) => a+b) != 0)
      await firestoreSleep(dayBegin, sleepTime, awakeTime, inBedTime);

    uploadPercent += 1;
    print("___________________\n$dayBegin - $dayEnd");
  }
  uploading = false;
  uploadPercent = 0;
}