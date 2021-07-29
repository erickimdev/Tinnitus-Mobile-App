import 'package:flutter/material.dart';
import 'package:fit_kit/fit_kit.dart';

class SmartwatchPage extends StatefulWidget {
  @override
  _SmartwatchPageState createState() => _SmartwatchPageState();
}

class _SmartwatchPageState extends State<SmartwatchPage> {
  String result = '';
  Map<DataType, List<FitData>> results = Map();
  bool permissions;

  RangeValues _dateRange = RangeValues(1, 8);
  List<DateTime> _dates = List<DateTime>();
  double _limitRange = 0;

  DateTime get _dateFrom => _dates[_dateRange.start.round()];
  DateTime get _dateTo => _dates[_dateRange.end.round()];
  int get _limit => _limitRange == 0.0 ? null : _limitRange.round();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _dates.add(null);
    for (int i = 7; i >= 0; i--) {
      _dates.add(DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i)));
    }
    _dates.add(null);

    hasPermissions();
  }

  Future<void> read() async {
    results.clear();

    try {
      permissions = await FitKit.requestPermissions(DataType.values);
      if (!permissions) result = 'requestPermissions: failed';
      else {
        for (DataType type in DataType.values) {
          try {
            results[type] = await FitKit.read(
              type,
              dateFrom: _dateFrom,
              dateTo: _dateTo,
              limit: _limit,
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

  Widget button(String _text, IconData _icon, String _route, double LR) {
    double multiplier = 1.5;
    return GestureDetector(
      child: Card(
        // color: Colors.black54,
        color: Colors.black54,
        child: Padding(
          padding: EdgeInsets.fromLTRB(LR*multiplier, 16*multiplier, LR*multiplier, 16*multiplier),
          // padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(
                _icon,
                color: Colors.blueAccent,
                size: 40,
              ),
              SizedBox(height: 2,),
              Text(
                _text,
                style: TextStyle(
                  fontSize: 23,
                  fontFamily: 'mont',
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        print("$_text");
        Navigator.pushNamed(context, _route);
      },
    );
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
              // Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              // Text(
              //     'Date Range: ${_dateToString(_dateFrom)} - ${_dateToString(_dateTo)}', style: TextStyle(color: Colors.white),),
              // Text('Limit: $_limit', style: TextStyle(color: Colors.white),),
              // Text('Permissions: $permissions', style: TextStyle(color: Colors.white),),
              // Text('Result: $result', style: TextStyle(color: Colors.white),),
              // _buildDateSlider(context),
              // _buildLimitSlider(context),
              // _buildButtons(context),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: items.length,
              //     itemBuilder: (context, index) {
              //       final item = items[index];
              //       if (item is DataType) {
              //         return Padding(
              //           padding: EdgeInsets.symmetric(vertical: 8),
              //           child: Text(
              //             '$item - ${results[item].length}',
              //             style: TextStyle(fontSize: 15, color: Colors.white,),
              //           ),
              //         );
              //       }
              //       else if (item is FitData) {
              //         return Padding(
              //           padding: EdgeInsets.symmetric(
              //             vertical: 4,
              //             horizontal: 8,
              //           ),
              //           child: Text(
              //             '???? $item',
              //             style: Theme.of(context).textTheme.caption,
              //           ),
              //         );
              //       }
              //
              //       return Container();
              //     },
              //   ),
              // ),

              SizedBox(height: 30.0),
              Icon(
                Icons.watch,
                color: Colors.white,
                size: 100,
              ),

              SizedBox(height: 100.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button("Step", Icons.directions_run, "/step", 24),
                  SizedBox(width: 20,),
                  button("Activity", Icons.directions_bike, "/activity", 13),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button("Sleep", Icons.bed, "/sleep", 20),
                  SizedBox(width: 20,),
                  button("Heart", Icons.favorite, "/heart", 21),
                ],
              ),
            ],
          ),
        ),

        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.red,
        //   onPressed: () {
        //     print("result: $result");
        //     print("results: $results");
        //   },
        //   child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
        // ),

      ),
    );
  }

  String _dateToString(DateTime dateTime) {
    if (dateTime == null) return 'null';
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  Widget _buildDateSlider(BuildContext context) {
    return Row(
      children: [
        Text('Date Range', style: TextStyle(color: Colors.white),),
        Expanded(
          child: RangeSlider(
            values: _dateRange,
            min: 0,
            max: 9,
            divisions: 10,
            onChanged: (values) => setState(() => _dateRange = values),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitSlider(BuildContext context) {
    return Row(
      children: [
        Text('Limit', style: TextStyle(color: Colors.white),),
        Expanded(
          child: Slider(
            value: _limitRange,
            min: 0,
            max: 4,
            divisions: 4,
            onChanged: (newValue) => setState(() => _limitRange = newValue),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
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
    );
  }

}
