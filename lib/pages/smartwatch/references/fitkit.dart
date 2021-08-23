import 'package:flutter/material.dart';
import 'package:fit_kit/fit_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class FitKitPage extends StatefulWidget {
  @override
  _FitKitPageState createState() => _FitKitPageState();
}

class _FitKitPageState extends State<FitKitPage> {
  Map<DataType, List<FitData>> results = Map();
  bool permissions;
  DateTime _dateFrom = DateTime(2021,7,1);
  DateTime _dateTo = DateTime(2021,8,30);

  Future<void> read() async {
    results.clear();

    permissions = await FitKit.requestPermissions(DataType.values);
    if (permissions) {
      for (var i in DataType.values) {
        try {
          results[i] = await FitKit.read(
            i,
            dateFrom: _dateFrom,
            dateTo: _dateTo,
          );
        } on UnsupportedException catch (e) {
          results[e.dataType] = [];
        }
      }
    }

    setState(() {});
  }

  Future<void> revokePermissions() async {
    results.clear();
    await FitKit.revokePermissions();
    permissions = await FitKit.hasPermissions(DataType.values);

    setState(() {});
  }

  Future<void> askPermissions() async {
    permissions = await FitKit.hasPermissions(DataType.values);
    await Permission.activityRecognition.request();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    askPermissions();
  }

  @override
  Widget build(BuildContext context) {
    var items = results.entries.expand((entry) => [entry.key, ...entry.value]).toList();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('FitKit Example'),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              Text('Permissions: $permissions'),

              // buttons
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      onPressed: () => read(),
                      child: Text('Read'),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    child: FlatButton(
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      onPressed: () => revokePermissions(),
                      child: Text('Revoke permissions'),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    var item = items[i];

                    // data types to read
                    if (item is DataType) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '$item - ${results[item].length}',
                          style: Theme.of(context).textTheme.title,
                        ),
                      );
                    }

                    // actual personal data
                    else if (item is FitData) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Text(
                          '${item.dateFrom} - ${item.value}',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      );
                    }

                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            print("items: $items");
          },
          child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
        ),

      ),
    );
  }
}
