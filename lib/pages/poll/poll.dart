import 'package:flutter/material.dart';

class PollPage extends StatefulWidget {
  @override
  _PollPageState createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
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

  void nextQuestion() {
    setState(() {
      if(groupValue() != null) {
        if(_index < 5) _index += 1;
        else if(_index == 5) submitQuestion();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please fill in an answer"
            ),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    });
  }
  void prevQuestion() {
    setState(() {
      if(_index > 0) _index -= 1;
      else if(_index == 0) print("cant go back");
    });
  }
  void submitQuestion() {
    setState(() {
      print("NO MOER!!!");
    });
  }

  // String _text, int _groupValue, int _value, int questionNum
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
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
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

      body: Center(
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
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  '${_questions[_index]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.7,
                    fontSize: 24.0,
                    // fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),

                // RADIO BUTTONS
                SizedBox(height: 24.0),
                radioButton("Never          ", groupValue(), 1, ),
                radioButton("Rarely         ", groupValue(), 2, ),
                radioButton("Sometimes", groupValue(), 3, ),
                radioButton("Often          ", groupValue(), 4, ),
                radioButton("Always       ", groupValue(), 5, ),

                // BACK/NEXT BUTTONS
                SizedBox(height: 35.0),
                Row(
                  children: [
                    SizedBox(width: 65),
                    TextButton.icon(
                      onPressed: prevQuestion,
                      icon: Icon(
                        Icons.subdirectory_arrow_left,
                        color: Colors.blue[300],
                        size: 30,
                      ),
                      label: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 27,
                          color: Colors.blue[200],
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    TextButton.icon(
                      onPressed: nextQuestion,
                      icon: Icon(
                        Icons.subdirectory_arrow_right,
                        color: Colors.blue[300],
                        size: 30,
                      ),
                      label: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 27,
                          color: Colors.blue[200],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          print("q1: $q1");
          print("q2: $q2");
          print("q3: $q3");
          print("q4: $q4");
          print("q5: $q5");
          print("q6: $q6");
          print("________");
        },
        child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
      ),
    );
  }
}