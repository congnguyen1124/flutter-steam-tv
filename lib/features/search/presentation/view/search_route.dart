import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/search/presentation/view/search_screen.dart';

final class SearchRoute extends StatelessWidget {
  const SearchRoute({super.key});

  static const String path = '/search';

  @override
  Widget build(BuildContext context) => const SearchScreen();
}
