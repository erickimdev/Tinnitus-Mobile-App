import 'package:health/health.dart';

HealthFactory health = HealthFactory();

// "current" date to read data
// DateTime d = DateTime(2021, 8, 12);
DateTime d = DateTime.now();
DateTime day = DateTime(d.year, d.month, d.day);

// time units for what range of data to read
DateTime dayBegin = new DateTime(day.year, day.month, day.day);
DateTime dayEnd = new DateTime(day.year, day.month, day.day, 23, 59, 59);
DateTime firstDayOfWeek = day.subtract(Duration(days: day.weekday % 7));
DateTime lastDayOfWeek = day.subtract(Duration(days: day.weekday % 7)).add(Duration(days: 7)).subtract(Duration(minutes: 1));
DateTime firstDayOfMonth = new DateTime(day.year, day.month, 1);
DateTime lastDayOfMonth = new DateTime(day.year, day.month, DateTime(day.year, day.month + 1, 0).day, 23, 59, 59);
