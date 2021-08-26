import 'package:health/health.dart';
import 'package:tinnitus_app/pages/smartwatch/parts/step.dart';
import '../../../FirestoreService.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../../main.dart';

HealthFactory health = HealthFactory();

// "current" date to read data
// DateTime d = DateTime(2021, 8, 18);
DateTime d = DateTime.now();
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