import 'package:intl/intl.dart';

class TimeSlot {
  final String start;
  final String end;

  TimeSlot({required this.start, required this.end});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'],
      end: json['end'],
    );
  }

  DateTime get startDateTime => DateFormat('HH:mm').parse(start);
  DateTime get endDateTime   => DateFormat('HH:mm').parse(end);
}
