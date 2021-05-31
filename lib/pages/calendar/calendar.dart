import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 69, 151, 1),

      appBar: AppBar(
        title: Text('Tinnitus Events Calendar'),
        centerTitle: true,
        backgroundColor: Colors.black54,
        elevation: 5,
      ),

      body: Column(
        children: [
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
                letterSpacing: 1.3,
              ),
              headerPadding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.blue[800],
              )
            ),

            // days of week style changes
            daysOfWeekStyle: DaysOfWeekStyle(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.rectangle,
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

          Divider(
            color: Colors.white,
            thickness: 1.3,
            height: 20,
            indent: 20,
            endIndent: 20,
          ),

          // TextButton.icon(onPressed: () {}, icon: new Icon(Icons.plus_one), label: Text("huh")),

          // list of events
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0,
                        ),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text(
                          '${value[index]}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          print("_focusedDay: $_focusedDay");
          print("_selectedDay: $_selectedDay");
          print("_selectedEvents: $_selectedEvents");
        },
        child: new Icon(Icons.add),
      ),

    );
  }
}

///////////////// HELPER FUNCTIONS /////////////////
