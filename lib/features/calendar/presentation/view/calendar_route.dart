import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/view/calendar_screen.dart';

final class CalendarRoute extends StatelessWidget {
  const CalendarRoute({super.key});

  static const String path = '/calendar';

  @override
  Widget build(BuildContext context) => const CalendarScreen();
}
