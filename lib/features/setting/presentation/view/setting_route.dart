import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/profile/presentation/view/profile_route.dart';
import 'package:flutter_steam_tv/features/setting/presentation/view/setting_screen.dart';
import 'package:go_router/go_router.dart';

final class SettingRoute extends StatelessWidget {
  const SettingRoute({super.key});

  static const String path = '/setting';

  @override
  Widget build(BuildContext context) {
    return SettingScreen(onOpenSignIn: () => context.go(ProfileRoute.path));
  }
}
