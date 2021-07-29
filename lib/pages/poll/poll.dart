import 'package:flutter/material.dart';
import '../../FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinnitus_app/main.dart';
import 'package:intl/intl.dart';

class PollPage extends StatefulWidget {
  @override
  _PollPageState createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  bool submitted;

  int q1;
  int q2;
  int q3;
  int q4;
  int q5;
  int q6;

  int groupValue() {
    if(_index == 0) return q1;
    else if(_index == 1) return q2;
    else if(_index == 2) return q3;
    else if(_index == 3) return q4;
    else if(_index == 4) return q5;
    else if(_index == 5) return q6;
    return null;
  }

  int _index = 0;
  List<String> _questions = [
    '\"I have been feeling\nstressed & nervous\"',
    '\"I have been feeling\ndepressed & sad\"',
    '\"I have been feeling\ntired or have little energy\"',
    '\"I have been satisfied\nwith my sleep\"',
    '\"I have been engaging in\nphysical activities I enjoy\"',
    '\"My social relationships have\nbeen supportive & rewarding\"',
  ];

  void updatePoll(int i) {
    setState(() {
      if(_index == 0) q1 = i;
      else if(_index == 1) q2 = i;
      else if(_index == 2) q3 = i;
      else if(_index == 3) q4 = i;
      else if(_index == 4) q5 = i;
      else if(_index == 5) q6 = i;
    });
  }

  Future<void> confirmSubmit() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Submit Answers?"),
          content: new Text("This will overwrite any existing data for today."),
          actions: <Widget>[
            new TextButton(
              child: new Text("CANCEL", style: TextStyle(fontSize: 15,),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("SUBMIT", style: TextStyle(fontSize: 15,),),
              onPressed: () async {
                if (user != null) {
                  await FirestoreService(uid: "${user.email}").updateDailyFeelings(q1, q2, q3, q4, q5, q6);
                  Navigator.of(context).pop();
                  setState(() {
                    dailySubmitted = true;
                  });
                }
                else print("not logged in");
              },
            ),
          ],
        );
      },
    );
  }

  void nextQuestion() {
    setState(() {
      if(groupValue() != null) {
        if(_index < 5) _index += 1;
        else if(_index == 5) submitQuestion();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please fill in an answer"),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    });
  }
  void prevQuestion() {
    setState(() {
      if(_index > 0) _index -= 1;
      // else if(_index == 0) print("cant go back");
    });
  }
  void submitQuestion() async {
    setState(() {
      confirmSubmit();
    });
  }

  Widget radioButton(String _text, int _groupValue, int _value, ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio(
          onChanged: (i) => updatePoll(i),
          groupValue: _groupValue,
          value: _value,
          activeColor: Colors.white,
          fillColor: MaterialStateColor.resolveWith((states) => Colors.white70),
        ),
        Text(
          _text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            fontFamily: 'mont-light',
          ),
        ),
      ],
    );
  }

  Widget _body(context, AsyncSnapshot<QuerySnapshot> snapshot) {
    // if(snapshot.data == null) return Center(child: CircularProgressIndicator());

    // check firebase if quiz was already taken
    if (snapshot.hasData) {
      String date = DateFormat('MM-dd-yyyy').format(DateTime.now());
      snapshot.data.docs.toList().forEach((i) {
        if (i.id == "$date") {
          dailySubmitted = true;
        }
      });
    }

    if (dailySubmitted) {
      return Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 185.0),
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 80,
            ),

            SizedBox(height: 40.0),
            Text("Your answers have\nbeen recorded.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),

            SizedBox(height: 20.0),
            // TextButton.icon(
            //   onPressed: () {
            //     setState(() {
            //       dailySubmitted = false;
            //     });
            //   },
            //   icon: Icon(Icons.logout),
            //   label: Text('Retake Quiz',
            //     style: TextStyle(
            //       fontSize: 16,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    }

    else {
      return Center(
        child: Column(
          children: <Widget>[
            // POLL ICON
            SizedBox(height: 30.0),
            Icon(
              Icons.poll,
              color: Colors.white,
              size: 80,
            ),
            SizedBox(height: 30.0),
            Column(
              children: [
                // QUESTION PROMPT
                Text(
                  'Question ${_index+1}/6',
                  style: TextStyle(
                    letterSpacing: 0.7,
                    fontSize: 23.0,
                    color: Colors.white70,
                    fontFamily: 'mont',
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  '${_questions[_index]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.7,
                    fontSize: 24,
                    color: Colors.grey[300],
                    fontFamily: 'mont',
                  ),
                ),
                // SizedBox(height: 20.0),
                // Divider(
                //   color: Colors.white,
                //   thickness: 0.6,
                //   height: 0,
                //   indent: 50,
                //   endIndent: 50,
                // ),

                // RADIO BUTTONS
                SizedBox(height: 18.0),
                radioButton("Never           ", groupValue(), 1, ),
                radioButton("Rarely          ", groupValue(), 2, ),
                radioButton("Sometimes", groupValue(), 3, ),
                radioButton("Often          ", groupValue(), 4, ),
                radioButton("Always        ", groupValue(), 5, ),

                // BACK/NEXT BUTTONS
                SizedBox(height: 25.0),
                Row(
                  children: [
                    SizedBox(width: 70),
                    TextButton.icon(
                      onPressed: prevQuestion,
                      icon: Icon(
                        Icons.subdirectory_arrow_left,
                        color: Colors.blue[300],
                        size: 28,
                      ),
                      label: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blue[200],
                          fontFamily: 'mont',
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    TextButton.icon(
                      onPressed: nextQuestion,
                      icon: Icon(
                        Icons.subdirectory_arrow_right,
                        color: Colors.blue[300],
                        size: 28,
                      ),
                      label: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blue[200],
                          fontFamily: 'mont',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Daily Questions'),
        centerTitle: true,
        backgroundColor: Colors.black12,
        elevation: 5,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users')
            .doc('${user.email}').collection("Daily Feelings").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return _body(context, snapshot);
        }
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   onPressed: () async {
      //     print("user: $user");
      //     print("q1: $q1");
      //     print("q2: $q2");
      //     print("q3: $q3");
      //     print("q4: $q4");
      //     print("q5: $q5");
      //     print("q6: $q6");
      //     print("________");
      //   },
      //   child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
      // ),

    );
  }
}