import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen.dart';
import 'package:flutter_steam_tv/features/main/presentation/navigation/main_navigation_origin.dart';
import 'package:flutter_steam_tv/features/main/presentation/view/main_screen.dart';
import 'package:flutter_steam_tv/features/main/presentation/view_model/top_bar_readability_view_model.dart';
import 'package:go_router/go_router.dart';

final class MainRoute extends ConsumerWidget {
  const MainRoute({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentBehindTopBar = currentPath == HomeScreen.path;

    return MainScreen(
      currentPath: currentPath,
      contentBehindTopBar: contentBehindTopBar,
      // Gated on the layout as well as on the request. A destination inset below the bar has nothing
      // behind it to protect, and leaving a stale request from Home visible after navigating away
      // would draw a band of surface colour over the top of an already-inset screen.
      showTopBarReadabilityLayer:
          contentBehindTopBar && ref.watch(topBarReadabilityProvider),
      onNavigate: (path) =>
          context.go(path, extra: MainNavigationOrigin.topBar),
      child: child,
    );
  }
}
