import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HealthKitPage extends StatefulWidget {
  @override
  _HealthKitPageState createState() => _HealthKitPageState();
}

enum AppState {
  DATA_NOT_FETCHED,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED
}

class _HealthKitPageState extends State<HealthKitPage> {
  HealthFactory health = HealthFactory();
  List<HealthDataPoint> _healthDataList = [];
  DateTime startDate = DateTime(2020, 07, 29, 0, 0, 0);
  DateTime endDate = DateTime(2022, 07, 29, 23, 59, 59);
  AppState _state = AppState.DATA_NOT_FETCHED;

  /// Define the types to get.
  List<HealthDataType> types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
  ];

  Future fetchData() async {
    setState(() {return CircularProgressIndicator;});

    /// You MUST request access to the data types before reading them
    bool accessWasGranted = await health.requestAuthorization(types);

    if (accessWasGranted) {
      try {
        /// Fetch new data
        List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(startDate, endDate, types);

        /// Save all the new data points
        _healthDataList.addAll(healthData);
      } catch (e) {}

      /// Filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      /// Update the UI to display the results
      setState(() {
        _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    }
    else {
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Widget _content() {
    if (_state == AppState.DATA_READY) {
      return ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];
          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text('${p.unitString}'),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        }
      );
    }

    else if (_state == AppState.NO_DATA) {
      return Text('No Data to show');
    }

    else if (_state == AppState.AUTH_NOT_GRANTED) {
      return Text('Authorization not given.');
    }

    return Text('Press the download button to fetch data');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {
                fetchData();
              },
            )
          ],
        ),
        body: Center(
          child: _content(),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            _healthDataList.forEach((i) {print("i: $i");});
          },
          child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
        ),

      ),
    );
  }
}
