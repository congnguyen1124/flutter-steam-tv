import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen.dart';
import 'package:flutter_steam_tv/features/home/presentation/view_model/home_view_model.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_route.dart';
import 'package:go_router/go_router.dart';

final class HomeRoute extends ConsumerWidget {
  const HomeRoute({super.key});

  static const String path = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeScreen(
      state: ref.watch(homeViewModelProvider),
      onRetry: ref.read(homeViewModelProvider.notifier).reload,
      onItemPressed: (item) => _play(context, item),
    );
  }

  /// Pushed, not navigated to, so Back on the remote returns to the row the viewer came from with
  /// focus where they left it.
  ///
  /// Home items carry no stream URL — nothing on the home screen plays — so only the id travels,
  /// and the player feature resolves it. That keeps home unaware of playback, which matters because
  /// several surfaces will eventually start it.
  void _play(BuildContext context, HomeItem item) {
    unawaited(context.push<void>(PlayerRoute.locationFor(item.id)));
  }
}
