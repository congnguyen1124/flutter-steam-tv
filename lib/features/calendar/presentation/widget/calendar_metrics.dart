import 'dart:math' as math;

import 'package:flutter_steam_tv/features/calendar/presentation/model/calendar_models.dart';

abstract final class CalendarMetrics {
  static const double leadingWidth = 76;
  static const double headerHeight = 64;
  static const double channelWidth = 214;
  static const double channelGap = 8;
  static const double hourHeight = 76;
  static const double columnPitch = channelWidth + channelGap;
  static const double selectedItemPadding = 2;
  static const double itemVerticalSpacing = 3;
  static const int beyondBoundsColumnCount = 1;
  static const int beyondBoundsMinuteCount = 120;

  static double programTop(CalendarProgram program) {
    return program.startMinute / 60 * hourHeight;
  }

  static double programHeight(CalendarProgram program) {
    return math.max(
      20,
      program.durationMinutes / 60 * hourHeight - itemVerticalSpacing,
    );
  }

  static double contentWidth(int channelCount) {
    if (channelCount == 0) {
      return 0;
    }
    return channelCount * channelWidth + (channelCount - 1) * channelGap;
  }

  static const double contentHeight = hourHeight * 24;
}
