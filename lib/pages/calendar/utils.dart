import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;
  final String time;

  const Event(this.title, this.time);

  @override
  String toString() => title;
}

LinkedHashMap<DateTime, List<Event>>
kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);
// ..addAll(_kEventSource);
//
// Map<DateTime, List<Event>>
// _kEventSource = Map.fromIterable(
//   List.generate(2, (index) => index),
//   key: (item) => DateTime.utc(2021, 5, item * 2),
//   value: (item) => List.generate(
//     item % 4 + 1, (index) => Event('Event $item | ${index + 1}')
//   )
// )
//   ..addAll({
//     DateTime.utc(2021, 6, 29): [
//       Event('Today\'s Event 1'),
//       Event('Today\'s Event 2'),
//       Event('Today\'s Event 333333'),
//     ],
//   });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}