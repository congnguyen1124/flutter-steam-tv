import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen.dart';
import 'package:flutter_steam_tv/features/home/presentation/view_model/home_view_model.dart';

final class HomeRoute extends ConsumerWidget {
  const HomeRoute({this.autofocusContent = true, super.key});

  static const String path = '/';

  final bool autofocusContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeScreen(
      state: ref.watch(homeViewModelProvider),
      autofocusContent: autofocusContent,
      onRetry: ref.read(homeViewModelProvider.notifier).reload,
      onItemPressed: (item) => _showItemDetails(context, item),
    );
  }

  void _showItemDetails(BuildContext context, HomeItem item) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(item.title),
          content: Text(item.description),
          actions: [
            TextButton(
              autofocus: true,
              onPressed: Navigator.of(context).pop,
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
