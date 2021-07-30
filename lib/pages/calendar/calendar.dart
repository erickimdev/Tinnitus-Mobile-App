import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'utils.dart';
import '../../FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinnitus_app/main.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;

  @override
  void initState() {
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));

    super.initState();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Future<bool> confirmDelete(String eventName, String date, String time) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete $eventName?"),
          content: new Text("This action cannot be undone"),
          actions: <Widget>[
            new TextButton(
              child: new Text("CANCEL", style: TextStyle(fontSize: 15,),),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            new TextButton(
              child: new Text("DELETE", style: TextStyle(fontSize: 15,),),
              onPressed: () async {
                Navigator.of(context).pop(true);
                await FirestoreService(uid: "${user.email}").removeTinnitusEvent(date, time);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users')
            .doc('${user.email}').collection("Tinnitus Event Calendar").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // sync user's firebase to calendar
          if(snapshot.data == null) return Center(child: CircularProgressIndicator());
          if (!calendarSynced) {
            calendarSynced = true;

            for (var i in snapshot.data.docs) {
              DateTime _day = new DateFormat("MM-dd-yyyy").parse(i.id.split(" ")[0]);
              String time = i.id.split(" ")[1] + " " + i.id.split(" ")[2];
              int _q1 = i["question 1"];
              int _q2 = i["question 2"];

              Event event = Event(
                  "Tinnitus Event", time, _q1, _q2, null, null, null, null);

              if (kEvents[_day] == null) kEvents.addAll({_day: [event,]});
              else kEvents[_day].add(event);

              _selectedEvents.value = _getEventsForDay(_selectedDay);
            }
          }

          return Column(
            children: [
              SizedBox(height: 50.0),

              TableCalendar<Event>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 3, 14),
                daysOfWeekHeight: 22,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                onDaySelected: _onDaySelected,
                pageJumpingEnabled: true,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },

                // header style changes
                headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                    ),
                    rightChevronIcon: Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    titleTextStyle: TextStyle(
                      fontSize: 22,
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                      letterSpacing: 0.6,
                    ),
                    headerPadding: EdgeInsets.symmetric(vertical: 4.5),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                    )
                ),
                // days of week style changes
                daysOfWeekStyle: DaysOfWeekStyle(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(7),
                      ),
                    ),
                    weekdayStyle: TextStyle(
                      color: Colors.grey[800],
                    ),
                    weekendStyle: TextStyle(
                      color: Colors.grey[800],
                    )
                ),
                // calendar style changes
                calendarStyle: CalendarStyle(
                  markerSize: 4,
                  defaultTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                  ),
                  outsideTextStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.5,
                  ),
                  todayTextStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.5,
                  ),
                  markerDecoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      shape: BoxShape.circle
                  ),
                ),
              ),

              SizedBox(height: 18.0),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 185, 0),
                    child: Text(
                      "Tinnitus Events",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 27,
                    ),
                    onPressed: () async {
                      // go to "Add Event" page
                      await Navigator.pushNamed(context, "/add_event", arguments: {
                        "day" : _selectedDay,
                      });

                      // update list view
                      setState(() {
                        _selectedEvents.value = _getEventsForDay(_selectedDay);
                      });
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Divider(
                color: Colors.white,
                thickness: 1.3,
                height: 0,
                indent: 20,
                endIndent: 20,
              ),

              // TINNITUS EVENTS
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 23.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Colors.grey[400],
                            ),
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () => print('${value[index]}'),
                            onLongPress: () {},
                            contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            subtitle: Text(
                              "Recorded at ${value[index].time}",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            title: Text(
                              '${value[index]}',
                              style: TextStyle(
                                color: Colors.grey[200],
                                fontSize: 16,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.grey[300],
                              ),
                              splashRadius: 20,
                              onPressed: () async {
                                String date = DateFormat('MM-dd-yyyy').format(_selectedDay);
                                String time = value[index].time;
                                bool choice = await confirmDelete("${value[index]}", date, time);
                                setState(() {
                                  if(choice) {
                                    value.removeAt(index);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              Divider(
                color: Colors.grey[500],
                thickness: 1.1,
                height: 0,
              ),
            ],
          );
        }
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   onPressed: () {
      //   },
      //   child: Text("DEBUG", style: TextStyle(color: Colors.blue[800])),
      // ),

    );
  }
}
