import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final String uid;
  FirestoreService({ this.uid });

  // Firestore instance
  CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  Stream<QuerySnapshot> get snapshot {
    return userCollection.snapshots();
  }

  // TINNITUS EVENT CALENDAR
    // add event
  Future<void> addTinnitusEvent(int q1, List<bool> q2, String date) async {
    String q2string = "";
    for (var i = 0; i < q2.length; i += 1) if (q2[i]) q2string += "$i ";
    q2string = q2string.substring(0, q2string.length-1);

    String time = DateFormat.jm().format(DateTime.now()).toString();
    String fullDate = "$date $time";
    return await userCollection.doc(uid).collection('Tinnitus Event Calendar').doc(fullDate).set({
      'question 1': q1 - 1,
      'question 2': q2string,
    });
  }
    // delete event
  Future<void> removeTinnitusEvent(String date, String time) async {
    String fullDate = "$date $time";
    return await userCollection.doc(uid).collection('Tinnitus Event Calendar').doc(fullDate).delete();
  }



  // DAILY FEELINGS
  Future<void> updateDailyFeelings(int q1, int q2, int q3, int q4, int q5, int q6) async {
    String date = DateFormat('MM-dd-yyyy').format(DateTime.now());
    String time = DateFormat.jm().format(DateTime.now()).toString();
    return await userCollection.doc(uid).collection('Daily Feelings').doc(date).set({
      'question 1': q1 - 1,
      'question 2': q2 - 1,
      'question 3': q3 - 1,
      'question 4': q4 - 1,
      'question 5': q5 - 1,
      'question 6': q6 - 1,
      'timestamp': time,
    });
  }



  // SMARTWATCH BEHAVIOROME
  // HEART
    // features
  Future<void> heartFeatures(DateTime day, int avgHR, int avgRestingHR, int avgWalkingHR, int maxHR, int minHR) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Heart').doc('Features').set({
      'Average Heart Rate': avgHR,
      'Average Resting Heart Rate': avgRestingHR,
      'Average Walking Heart Rate': avgWalkingHR,
      'Maximum Heart Rate': maxHR,
      'Minimum Heart Rate': minHR,
    });
  }
    // hourly heart rate
  Future<void> hourlyHeartRate(DateTime day, Map<String, int> hourlyHRs) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Heart').doc('Hourly Heart Rate').set(hourlyHRs);
  }


  // STEP
    // features
  Future<void> stepFeatures(DateTime day, int steps, int distance) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Step').doc('Features').set({
      'Total Step Count': steps,
      'Total Distance': distance,
    });
  }
    // hourly step count
  Future<void> hourlySteps(DateTime day, Map<String, int> hourlySteps) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Step').doc('Accumulated Hourly Step Count').set(hourlySteps);
  }
    // hourly distance
  Future<void> hourlyDistance(DateTime day, Map<String, int> hourlyDistance) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Step').doc('Accumulated Hourly Distance').set(hourlyDistance);
  }


  // ACTIVITY
    // features
  Future<void> activityFeatures(DateTime day, int burned, int MM) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Activity').doc('Features').set({
      'Total Active Energy Burned': burned,
      'Total Movement Minutes': MM,
    });
  }
    // hourly calories burned
  Future<void> hourlyCalories(DateTime day, Map<String, int> hourlyBurned) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Activity').doc('Accumulated Hourly Energy Burned').set(hourlyBurned);
  }
    // hourly movement minutes
  Future<void> hourlyMovementMins(DateTime day, Map<String, int> hourlyMM) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Activity').doc('Accumulated Hourly Movement Minutes').set(hourlyMM);
  }


  // SLEEP
    // features
  Future<void> sleepFeatures(DateTime day, int asleep, int awake, int inBed) async {
    String date = DateFormat('MM-dd-yyyy').format(day).toString();
    return await userCollection.doc(uid).collection('Behaviorome').doc(date)
        .collection('Sleep').doc('Features').set({
      'Time Asleep': asleep,
      'Time Awake': awake,
      'Time in Bed': inBed,
    });
  }
}