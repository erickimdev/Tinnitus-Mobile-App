import 'package:flutter/material.dart';
import 'package:fit_kit/fit_kit.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String result = '';
  Map<DataType, List<FitData>> results = Map();
  bool permissions;
  DateTime _dateFrom = DateTime(2021,7,1);
  DateTime _dateTo = DateTime(2021,7,30);

  @override
  void initState() {
    super.initState();

    hasPermissions();
  }

  Future<void> read() async {
    results.clear();

    try {
      permissions = await FitKit.requestPermissions(DataType.values);
      print("permissions: $permissions");
      if (!permissions) result = 'requestPermissions: failed';
      else {
        for (DataType i in DataType.values) {
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
        result = 'readAll: success';
      }
    } catch (e) {
      result = 'readAll: $e';
    }

    setState(() {});
  }

  Future<void> hasPermissions() async {
    try {
      permissions = await FitKit.hasPermissions(DataType.values);
    } catch (e) {
      result = 'hasPermissions: $e';
    }

    if (!mounted) return;

    setState(() {});
  }
  Future<void> revokePermissions() async {
    results.clear();

    try {
      await FitKit.revokePermissions();
      permissions = await FitKit.hasPermissions(DataType.values);
      result = 'revokePermissions: success';
    } catch (e) {
      result = 'revokePermissions: $e';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = results.entries.expand((entry) => [entry.key, ...entry.value]).toList();

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromRGBO(34, 69, 151, 1),

        appBar: AppBar(
          title: Text('Behaviorome', style: TextStyle(fontFamily: 'mont-med'),),
          centerTitle: true,
          backgroundColor: Colors.black12,
          elevation: 5,
        ),

        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              Text('Permissions: $permissions', style: TextStyle(color: Colors.white),),
              Text('Result: $result', style: TextStyle(color: Colors.white),),

              Row(
                children: [
                  Expanded(
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      color: Theme.of(context).accentColor,
                      textColor: Colors.white,
                      onPressed: () => read(),
                      child: Text('Read'),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                  Expanded(
                    // ignore: deprecated_member_use
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
                  itemBuilder: (context, index) {
                    final i = items[index];

                    if (i is DataType) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '$i - ${results[i]}',
                          style: TextStyle(fontSize: 15, color: Colors.white,),
                        ),
                      );
                    }

                    else if (i is FitData) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Text(
                          '???? $i',
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
          onPressed: () async {
            FitData result = await FitKit.readLast(DataType.HEIGHT);
            print("result: $result");
          },
          child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
        ),

      ),
    );
  }
}
