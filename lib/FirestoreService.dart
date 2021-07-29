import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final String uid;
  FirestoreService({ this.uid });

  // Firestore instance
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  Stream<QuerySnapshot> get snapshot {
    return userCollection.snapshots();
  }

  // TINNITUS EVENT CALENDAR
  // add event
  Future<void> addTinnitusEvent(int q1, int q2, String date) async {
    String time = DateFormat.jm().format(DateTime.now()).toString();
    String fullDate = "$date $time";
    return await userCollection.doc(uid)
        .collection('Tinnitus Event Calendar').doc(fullDate).set({
      'question 1': q1 - 1,
      'question 2': q2 - 1,
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

}