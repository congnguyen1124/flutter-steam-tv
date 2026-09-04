import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen.dart';
import 'package:flutter_steam_tv/features/main/presentation/navigation/main_navigation_origin.dart';
import 'package:flutter_steam_tv/features/main/presentation/view/main_screen.dart';
import 'package:go_router/go_router.dart';

final class MainRoute extends StatelessWidget {
  const MainRoute({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      currentPath: currentPath,
      contentBehindTopBar: currentPath == HomeScreen.path,
      onNavigate: (path) =>
          context.go(path, extra: MainNavigationOrigin.topBar),
      child: child,
    );
  }
}
