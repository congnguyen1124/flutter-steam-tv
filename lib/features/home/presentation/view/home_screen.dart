import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/view_model/home_view_model.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_content_view.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_error_view.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_loading_view.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_route.dart';
import 'package:go_router/go_router.dart';

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
      onItemPressed: (item) => _play(context, item),
    );
  }

  /// Pushed rather than navigated to, so Back on the remote returns to this row with focus where
  /// the viewer left it — `go` would rebuild Home from scratch and drop that.
  ///
  /// Only the id travels. The player resolves the item from the same catalogue Home read, which is
  /// what keeps the two from drifting: passing the whole `HomeItem` through navigation would work
  /// today and break the first time a deep link opens the player directly.
  void _play(BuildContext context, HomeItem item) {
    unawaited(context.push<void>(PlayerRoute.locationFor(item.id)));
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
