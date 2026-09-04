import 'package:flutter/foundation.dart';

enum SteamTopBarItemRole { destination, profile }

@immutable
final class SteamTopBarItem {
  const SteamTopBarItem({
    required this.id,
    required this.iconAsset,
    required this.label,
    this.role = .destination,
  });

  final String id;
  final String iconAsset;
  final String label;
  final SteamTopBarItemRole role;
}
