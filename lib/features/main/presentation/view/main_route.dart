import 'package:flutter/material.dart';
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
      onNavigate: context.go,
      child: child,
    );
  }
}
