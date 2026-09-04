import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/widgets/steam_top_bar_item.dart';
import 'package:flutter_steam_tv/features/calendar/presentation/view/calendar_route.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen.dart';
import 'package:flutter_steam_tv/features/profile/presentation/view/profile_route.dart';
import 'package:flutter_steam_tv/features/search/presentation/view/search_route.dart';
import 'package:flutter_steam_tv/features/setting/presentation/view/setting_route.dart';

abstract final class MainTopBarItems {
  static const SteamTopBarItem search = SteamTopBarItem(
    id: 'search',
    iconAsset: AppAssets.searchIcon,
    label: 'Search',
  );
  static const SteamTopBarItem home = SteamTopBarItem(
    id: 'home',
    iconAsset: AppAssets.homeIcon,
    label: 'Home',
  );
  static const SteamTopBarItem calendar = SteamTopBarItem(
    id: 'calendar',
    iconAsset: AppAssets.calendarIcon,
    label: 'Calendar',
  );
  static const SteamTopBarItem setting = SteamTopBarItem(
    id: 'setting',
    iconAsset: AppAssets.settingIcon,
    label: 'Setting',
  );
  static const SteamTopBarItem profile = SteamTopBarItem(
    id: 'profile',
    iconAsset: AppAssets.profileIcon,
    label: 'Profile',
    role: .profile,
  );

  static const List<SteamTopBarItem> defaults = [
    search,
    home,
    calendar,
    setting,
    profile,
  ];

  static const Map<String, String> _pathsByItemId = {
    'search': SearchRoute.path,
    'home': HomeScreen.path,
    'calendar': CalendarRoute.path,
    'setting': SettingRoute.path,
    'profile': ProfileRoute.path,
  };

  static String pathFor(SteamTopBarItem item) {
    return _pathsByItemId[item.id]!;
  }

  static SteamTopBarItem itemForPath(String path) {
    return defaults.firstWhere(
      (item) => _pathsByItemId[item.id] == path,
      orElse: () => home,
    );
  }
}
