import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/profile/presentation/view/profile_screen.dart';

final class ProfileRoute extends StatelessWidget {
  const ProfileRoute({super.key});

  static const String path = '/profile';

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}
