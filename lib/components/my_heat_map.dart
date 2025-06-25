import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHeatMap extends StatelessWidget {
  final DateTime startDate;
  final bool isDarkMode;
  final Map<DateTime, int>? datasets;

  const MyHeatMap({
    super.key,
    required this.isDarkMode,
    required this.startDate,
    required this.datasets,
  });

  Color getColorForValue(int value) {
    if (value >= 5) return Colors.blue.shade600;
    if (value == 4) return Colors.blue.shade500;
    if (value == 3) return Colors.blue.shade400;
    if (value == 2) return Colors.blue.shade300;
    if (value == 1) return Colors.blue.shade200;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(startDate.year, startDate.month, startDate.day),
      lastDay: DateTime.now(),
      focusedDay: DateTime.now(),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      calendarStyle: CalendarStyle(outsideDaysVisible: false),
      //ui for the whole calendar
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final normalized = DateTime(day.year, day.month, day.day);
          final count = datasets?[normalized] ?? 0;
          final bgColor = getColorForValue(count);

          return Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        },
        //ui for just current day
        todayBuilder: (context, day, focusedDay) {
          final normalized = DateTime(day.year, day.month, day.day);
          final count = datasets?[normalized] ?? 0;
          final bgColor = getColorForValue(count);

          return Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          );
        },
      ),
    );
  }
}
