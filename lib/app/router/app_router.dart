import 'package:flutter_steam_tv/features/calendar/presentation/view/calendar_route.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_route.dart';
import 'package:flutter_steam_tv/features/main/presentation/navigation/main_navigation_origin.dart';
import 'package:flutter_steam_tv/features/main/presentation/view/main_route.dart';
import 'package:flutter_steam_tv/features/profile/presentation/view/profile_route.dart';
import 'package:flutter_steam_tv/features/search/presentation/view/search_route.dart';
import 'package:flutter_steam_tv/features/setting/presentation/view/setting_route.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: HomeRoute.path,
    routes: [
      ShellRoute(
        builder: (_, state, child) {
          return MainRoute(currentPath: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: HomeRoute.path,
            builder: (_, state) => HomeRoute(
              autofocusContent: state.extra != MainNavigationOrigin.topBar,
            ),
          ),
          GoRoute(
            path: SearchRoute.path,
            builder: (_, _) => const SearchRoute(),
          ),
          GoRoute(
            path: CalendarRoute.path,
            builder: (_, _) => const CalendarRoute(),
          ),
          GoRoute(
            path: SettingRoute.path,
            builder: (_, _) => const SettingRoute(),
          ),
          GoRoute(
            path: ProfileRoute.path,
            builder: (_, _) => const ProfileRoute(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
