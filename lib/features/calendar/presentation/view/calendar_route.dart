import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/view/calendar_screen.dart';

final class CalendarRoute extends StatelessWidget {
  const CalendarRoute({super.key});

  static const String path = '/calendar';

  @override
  Widget build(BuildContext context) => const CalendarScreen();
}

@Preview(name: 'Calendar route', size: Size(1280, 720))
Widget calendarRoutePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: StreamTvTheme.dark,
    home: const CalendarRoute(),
  );
}
