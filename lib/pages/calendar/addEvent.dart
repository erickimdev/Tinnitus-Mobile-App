import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'utils.dart';
import '../../services/firestore.dart';
import 'package:tinnitus_app/main.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  Map data = {};
  // questionnaire answers
  int q1;
  List<bool> q2 = [false, false, false, false, false];

  Widget radio(String _text, int _groupValue, int _value) {
    return Row(
      children: [
        Radio(
          onChanged: (i) {
            setState(() => q1 = i);
          },
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
  Widget radioCard(String question, int qNum) {
    List<Widget> questions = [
      radio("Less Bothersome", q1, 1),
      radio("No Change", q1, 2),
      radio("Bothersome", q1, 3),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 250, 0),
          child: Text(
            'QUESTION $qNum/2',
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
          color: Colors.black12,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
              color: Colors.grey[400],
              width: 1,
            ),
          ),
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
                  color: Colors.grey[200],
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
  Widget checkboxCard() {
    List<String> answers = [
      "Happy & Relaxed",
      "No Change",
      "Tired & Sad",
      "Anxious",
      "Depressed",
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 250, 0),
          child: Text(
            'QUESTION 2/2',
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
          color: Colors.black12,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
              color: Colors.grey[400],
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                child: Text(
                  "Select your emotions & anxiety events (multiple choices)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    // letterSpacing:
                  ),
                ),
              ),
              Divider(
                color: Colors.grey[200],
                thickness: 1.1,
                height: 30,
                indent: 15,
                endIndent: 15,
              ),
              for (var i = 0; i < 5; i += 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: q2[i],
                        onChanged: i == 5 ? null : (bool value) {
                          setState(() {
                            q2[i] = value;
                          });
                        },
                        side: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      Text(
                        answers[i],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ]
                  ),
                ),
                SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
  bool noCheckboxFilled() {
    if (q2[0] == false && q2[1] == false && q2[2] == false
        && q2[3] == false && q2[4] == false) return true;
    else return false;
  }

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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 12),
              radioCard('How do you feel about your tinnitus?', 1),
              checkboxCard(),

              // FloatingActionButton(
              //   onPressed: () {
              //     String q2 = "0 1 3";
              //     List<String> q2split = q2.split(" ");
              //     List<bool> q2list = new List(5);
              //     for (var i = 0; i < 5; i++) {
              //       if (q2split.contains(i.toString())) q2list[i] = true;
              //       else q2list[i] = false;
              //     }
              //     print("q2List: $q2list");
              //   },
              //   backgroundColor: Colors.red,
              //   child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
              // ),

              SizedBox(height: 60.0),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // one or more questions left blank
          if(q1 == null || noCheckboxFilled()) {
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
                q1, q2
            );

            // add this event to the current list of events
            setState(() {
              if (kEvents[_selectedDay] == null) kEvents.addAll({_selectedDay: [event,]});
              else kEvents[_selectedDay].add(event);
            });

            // upload to firebase
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