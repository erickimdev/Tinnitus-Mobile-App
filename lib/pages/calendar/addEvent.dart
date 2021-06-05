import 'package:flutter/material.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  Map data = {};

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Enter Tinnitus Event'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            // RECORD ICON
            SizedBox(height: 100.0),
            Icon(
              Icons.add,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 40.0),
            Text(
              'asdfasdfasdfasdfasdf',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),

            // RECORD BUTTON
            SizedBox(height: 130.0),
            TextButton.icon(
              onPressed: () async {
                print("data!!!!: $data");
                setState(() {});
              },
              icon: Icon(
                Icons.add_to_queue_sharp,
                color: Colors.white70,
                size: 40,
              ),
              label: Text(
                "CLICK ME!!!",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 25,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}