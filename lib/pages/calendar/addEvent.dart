import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'utils.dart';
import '../../FirestoreService.dart';
import 'package:tinnitus_app/main.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  Map data = {};
  // questionnaire answers
  int q1;
  int q2;
  int q3;
  int q4;
  int q5;
  int q6;

  void updatePoll(int i, int questionNum) {
    setState(() {
      if(questionNum == 1) q1 = i;
      else if(questionNum == 2) q2 = i;
      else if(questionNum == 3) q3 = i;
      else if(questionNum == 4) q4 = i;
      else if(questionNum == 5) q5 = i;
      else if(questionNum == 6) q6 = i;
    });
  }

  Widget poll(String _text, int _groupValue, int _value, int questionNum) {
    return Row(
      children: [
        Radio(
          onChanged: (i) => updatePoll(i, questionNum),
          groupValue: _groupValue,
          value: _value,
          activeColor: Colors.white,
          fillColor: MaterialStateColor.resolveWith((states) => Colors.white70),
        ),
        Text(
          _text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'mont-light',
          ),
        ),
      ],
    );
  }

  Widget questionCard(String question, List<Widget> questions, int qNum) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 250, 0),
          child: Text(
            'Question $qNum/2',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'mont',
              letterSpacing: 0.9,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.fromLTRB(22.0, 11.0, 22.0, 23.0),
          // color: Colors.blue[800],
          color: Colors.blue[700],
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    // letterSpacing:
                  ),
                ),
                Divider(
                  color: Colors.amberAccent,
                  thickness: 1.1,
                  height: 30,
                ),
              ]..addAll(questions),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    List<Widget> q1Answers = [
      poll("Less Bothersome", q1, 1, 1),
      poll("No Change", q1, 2, 1),
      poll("Bothersome", q1, 3, 1),
    ];
    List<Widget> q2Answers = [
      poll("Happy & Relaxed", q2, 1, 2),
      poll("No Change", q2, 2, 2),
      poll("Tired & Sad", q2, 3, 2),
      poll("Anxious", q2, 4, 2),
      poll("Depressed", q2, 5, 2),
    ];
    // List<Widget> q1Answers = [
    //   poll("Less than half an hour", q1, 1, 1),
    //   poll("1 to 3 hours", q1, 2, 1),
    //   poll("3 to 12 hours", q1, 3, 1),
    //   poll("12+ hours", q1, 4, 1),
    // ];
    // List<Widget> q2Answers = [ poll("Yes", q2, 1, 2), poll("Sometimes", q2, 2, 2), poll("No", q2, 3, 2), ];
    // List<Widget> q3Answers = [ poll("Yes", q3, 1, 3), poll("Sometimes", q3, 2, 3), poll("No", q3, 3, 3), ];
    // List<Widget> q4Answers = [ poll("Yes", q4, 1, 4), poll("Sometimes", q4, 2, 4), poll("No", q4, 3, 4), ];
    // List<Widget> q5Answers = [ poll("Yes", q5, 1, 5), poll("Sometimes", q5, 2, 5), poll("No", q5, 3, 5), ];
    // List<Widget> q6Answers = [ poll("Yes", q6, 1, 6), poll("Sometimes", q6, 2, 6), poll("No", q6, 3, 6), ];

    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Enter Tinnitus Event'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 12),
              questionCard('How do you feel about your tinnitus?', q1Answers, 1),
              questionCard('Select all your current emotion & anxiety feelings (multiple choices):', q2Answers, 2),
              // questionCard('What is the lasting time of this tinnitus event?', q1Answers, 1),
              // questionCard('Does your tinnitus make you feel anxious?', q2Answers, 2),
              // questionCard('Does your tinnitus make you feel angry?', q3Answers, 3),
              // questionCard('Because of your tinnitus, do you feel depressed?', q4Answers, 4),
              // questionCard('Because of your tinnitus, is it difficult for you to concentrate?', q5Answers, 5),
              // questionCard('Because of your tinnitus, do you have trouble falling asleep at night?', q6Answers, 6),
              SizedBox(height: 60.0),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // one or more questions left blank
          if(q1 == null || q2 == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please fill in all answers"),
                duration: Duration(milliseconds: 3000),
              ),
            );
          }

          // not logged in
          else if(user == null) print("not logged in");

          // all questions answered - ready to submit
          else {
            DateTime _selectedDay = data["day"];
            Event event = Event(
                "Tinnitus Event",
                "${DateFormat.jm().format(DateTime.now())}",
                q1, q2, q3, q4, q5, q6
            );

            setState(() {
              if (kEvents[_selectedDay] == null) {
                kEvents.addAll({_selectedDay: [event,]});
              }
              else {
                kEvents[_selectedDay].add(event);
              }
            });

            String date = DateFormat('MM-dd-yyyy').format(_selectedDay);
            await FirestoreService(uid: "${user.email}").addTinnitusEvent(q1, q2, date);

            Navigator.pop(context);
          }
        },
        icon: Icon(
          Icons.add,
          color: Colors.black87,
        ),
        label: Text(
          "Add Event",
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'mont',
          ),
        ),
        backgroundColor: Colors.amberAccent,
      ),
    );
  }
}