import 'package:flutter/material.dart';

final class CalendarDay {
  const CalendarDay({required this.dateLabel, required this.channels});

  final String dateLabel;
  final List<CalendarChannel> channels;
}

final class CalendarChannel {
  const CalendarChannel({
    required this.id,
    required this.title,
    required this.logoUrl,
    required this.programs,
  });

  final String id;
  final String title;
  final String logoUrl;
  final List<CalendarProgram> programs;

  String get initials {
    return title
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word.substring(0, 1))
        .join()
        .toUpperCase();
  }

  Color get accentColor {
    const palette = [
      Color(0xFF2E7D68),
      Color(0xFF28669B),
      Color(0xFF6D4A8F),
      Color(0xFF9A5A35),
      Color(0xFF8A3E59),
    ];
    return palette[id.hashCode.abs() % palette.length];
  }
}

final class CalendarProgram {
  const CalendarProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.startMinute,
    required this.endMinute,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int startMinute;
  final int endMinute;

  int get durationMinutes => endMinute - startMinute;
  String get timeLabel =>
      '${calendarClock(startMinute)} - ${calendarClock(endMinute)}';
}

String calendarClock(int minute) {
  final bounded = minute.clamp(0, 1440);
  if (bounded == 1440) {
    return '24:00';
  }
  final hour = bounded ~/ 60;
  final minutes = bounded % 60;
  return '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}
