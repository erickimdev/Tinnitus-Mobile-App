import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:table_calendar/table_calendar.dart';
import 'utils.dart';

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
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  List<Event> _getEventsForDay(DateTime day) => kEvents[day] ?? [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Future<bool> _showDialog(String eventName) async {
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
              onPressed: () {
                Navigator.of(context).pop(true);
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

      body: Column(
        children: [
          SizedBox(height: 50.0),

          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
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
            pageJumpingEnabled: true,

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
                fontSize: 24,
                color: Color.fromRGBO(255, 255, 255, 0.8),
                letterSpacing: 0.6,
              ),
              headerPadding: EdgeInsets.symmetric(vertical: 4.5),
              decoration: BoxDecoration(
                color: Colors.blue[800],
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
                fontSize: 18,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              outsideTextStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
              todayTextStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
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
                    fontSize: 20,
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
                onPressed: () {
                  print("_focusedDay: $_focusedDay");
                  print("_selectedDay: $_selectedDay");
                  print("_selectedEvents: $_selectedEvents");
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

          // list of events
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
                        title: Text(
                          '${value[index]}',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 16,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            bool choice = await _showDialog("${value[index]}");
                            setState(() {
                              if(choice){
                                value.removeAt(index);
                              }
                            });
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.grey[300],
                          ),
                          splashRadius: 20,
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
      ),
    );
  }
}

///////////////// HELPER FUNCTIONS /////////////////
