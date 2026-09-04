import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_content_view.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_error_view.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_loading_view.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.state,
    required this.onRetry,
    required this.onItemPressed,
    super.key,
  });

  final AsyncValue<List<HomeSection>> state;
  final VoidCallback onRetry;
  final ValueChanged<HomeItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    final content = switch (state) {
      AsyncData(:final value) => HomeContentView(
        sections: value,
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
