import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/features/main/presentation/view/main_screen.dart';
import 'package:flutter_steam_tv/features/profile/presentation/view/profile_route.dart';
import 'package:flutter_steam_tv/features/profile/presentation/view/profile_screen.dart';
import 'package:flutter_steam_tv/features/search/presentation/view/search_route.dart';
import 'package:flutter_steam_tv/features/search/presentation/view/search_screen.dart';

@Preview(
  name: 'Main shell - search',
  group: 'Main navigation',
  size: Size(1280, 720),
)
Widget mainSearchPreview() {
  return _preview(path: SearchRoute.path, child: const SearchScreen());
}

@Preview(
  name: 'Main shell - profile',
  group: 'Main navigation',
  size: Size(1280, 720),
)
Widget mainProfilePreview() {
  return _preview(path: ProfileRoute.path, child: const ProfileScreen());
}

Widget _preview({required String path, required Widget child}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: StreamTvTheme.dark,
    home: MainScreen(currentPath: path, onNavigate: (_) {}, child: child),
  );
}
