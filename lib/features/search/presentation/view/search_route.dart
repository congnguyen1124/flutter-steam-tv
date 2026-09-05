import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_route.dart';
import 'package:flutter_steam_tv/features/search/presentation/view/search_screen.dart';
import 'package:go_router/go_router.dart';

final class SearchRoute extends StatelessWidget {
  const SearchRoute({super.key});

  static const String path = '/search';

  @override
  Widget build(BuildContext context) {
    return SearchScreen(
      onItemPressed: (item) => context.push(PlayerRoute.locationFor(item.id)),
    );
  }
}
