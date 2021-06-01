import 'package:flutter/material.dart';

class PollPage extends StatefulWidget {
  @override
  _PollPageState createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  int _gradeSelected;

  void updatePoll(int i) {
    setState(() {
      if (i == 1) _gradeSelected = 1;
      else if (i == 2) _gradeSelected = 2;
      else if (i == 3) _gradeSelected = 3;
      else if (i == 4) _gradeSelected = 4;
    });
  }

  void submitAnswer() {
    setState(() {
      print("selected: " + _gradeSelected.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      body: Center(
        child: Column(
          children: <Widget>[
            // POLL ICON
            SizedBox(height: 100.0),
            Icon(
              Icons.poll,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 80.0),
            Column(
              children: [
                // QUESTION PROMPT
                Text(
                  'What grade are you in?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),

                // FRESHMEN RADIO BUTTON
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      onChanged: (i) => updatePoll(i),
                      groupValue: _gradeSelected,
                      value: 1,
                      activeColor: Colors.white,
                    ),
                    Text(
                      "Freshmen   ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                // SOPHOMORE RADIO BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      onChanged: (i) => updatePoll(i),
                      groupValue: _gradeSelected,
                      value: 2,
                      activeColor: Colors.white,
                    ),
                    Text(
                      "Sophomore",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                // JUNIOR RADIO BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      onChanged: (i) => updatePoll(i),
                      groupValue: _gradeSelected,
                      value: 3,
                      activeColor: Colors.white,
                    ),
                    Text(
                      "Junior          ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                // SENIOR RADIO BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      onChanged: (i) => updatePoll(i),
                      groupValue: _gradeSelected,
                      value: 4,
                      activeColor: Colors.white,
                    ),
                    Text(
                      "Senior          ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                // SUBMIT BUTTON
                SizedBox(height: 20.0),
                TextButton.icon(
                  onPressed: submitAnswer,
                  icon: Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  label: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}