import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/view_model/home_view_model.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_content_view.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_error_view.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_loading_view.dart';

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({this.autofocusContent = true, super.key});

  static const String path = '/';

  final bool autofocusContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeLceView(
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
            TextButton.icon(
              autofocus: true,
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

final class HomeLceView extends StatelessWidget {
  const HomeLceView({
    required this.state,
    required this.onRetry,
    required this.onItemPressed,
    this.autofocusContent = true,
    this.autoPlayBanners = true,
    super.key,
  });

  final AsyncValue<List<HomeSection>> state;
  final VoidCallback onRetry;
  final ValueChanged<HomeItem> onItemPressed;
  final bool autofocusContent;
  final bool autoPlayBanners;

  @override
  Widget build(BuildContext context) {
    final content = switch (state) {
      AsyncData(:final value) => HomeContentView(
        sections: value,
        autofocusContent: autofocusContent,
        autoPlayBanners: autoPlayBanners,
        onItemPressed: onItemPressed,
      ),
      AsyncError(:final error) => HomeErrorView(
        message: _messageFor(error),
        onRetry: onRetry,
      ),
      _ => const HomeLoadingView(),
    };

    return Material(color: Colors.transparent, child: content);
  }

  String _messageFor(Object error) {
    if (error case StateError(:final message)) {
      return message;
    }
    return 'Unable to load Home content';
  }
}
