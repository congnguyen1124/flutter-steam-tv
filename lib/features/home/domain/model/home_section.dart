import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';

final class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<HomeItem> items;
}
