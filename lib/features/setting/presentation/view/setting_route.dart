import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/setting/presentation/view/setting_screen.dart';

final class SettingRoute extends StatelessWidget {
  const SettingRoute({super.key});

  static const String path = '/setting';

  @override
  Widget build(BuildContext context) => const SettingScreen();
}
