import 'package:flutter_steam_tv/features/home/presentation/view/home_route.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_route.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: HomeRoute.path,
    routes: [
      GoRoute(path: HomeRoute.path, builder: (_, _) => const HomeRoute()),
      GoRoute(
        path: PlayerRoute.path,
        builder: (_, state) =>
            PlayerRoute(itemId: state.pathParameters['itemId'] ?? ''),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
