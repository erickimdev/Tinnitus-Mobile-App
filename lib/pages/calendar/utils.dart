import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;
  final String time;
  final int q1;
  final int q2;
  final int q3;
  final int q4;
  final int q5;
  final int q6;

  const Event(this.title, this.time, this.q1, this.q2, this.q3, this.q4, this.q5, this.q6);

  @override
  String toString() => title;
}

LinkedHashMap<DateTime, List<Event>>
kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}