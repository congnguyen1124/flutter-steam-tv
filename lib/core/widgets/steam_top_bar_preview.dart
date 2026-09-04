import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_item.dart';

@Preview(
  name: 'Steam top bar',
  group: 'Core design system',
  size: Size(1280, 720),
)
Widget steamTopBarPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: StreamTvTheme.dark,
    home: Scaffold(
      body: Align(
        alignment: .topCenter,
        child: SteamTopBar(
          items: _previewItems,
          selectedItemId: 'home',
          onItemPressed: (_) {},
        ),
      ),
    ),
  );
}

const List<SteamTopBarItem> _previewItems = [
  SteamTopBarItem(
    id: 'search',
    iconAsset: AppAssets.searchIcon,
    label: 'Search',
  ),
  SteamTopBarItem(id: 'home', iconAsset: AppAssets.homeIcon, label: 'Home'),
  SteamTopBarItem(
    id: 'calendar',
    iconAsset: AppAssets.calendarIcon,
    label: 'Calendar',
  ),
  SteamTopBarItem(
    id: 'setting',
    iconAsset: AppAssets.settingIcon,
    label: 'Setting',
  ),
  SteamTopBarItem(
    id: 'profile',
    iconAsset: AppAssets.profileIcon,
    label: 'Profile',
    role: .profile,
  ),
];
