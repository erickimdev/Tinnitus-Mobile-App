import 'package:flutter/material.dart';

class SmartwatchPage extends StatefulWidget {
  @override
  _SmartwatchPageState createState() => _SmartwatchPageState();
}

class _SmartwatchPageState extends State<SmartwatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Behaviorome'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            // SMARTWATCH ICON
            SizedBox(height: 30.0),
            Icon(
              Icons.watch,
              color: Colors.white,
              size: 80,
            ),

            // RECORD BUTTON
            SizedBox(height: 130.0),
            TextButton.icon(
              onPressed: () async {
                setState(() {});
              },
              icon: Icon(
                Icons.add_to_queue_sharp,
                color: Colors.white70,
                size: 40,
              ),
              label: Text(
                "Record",
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