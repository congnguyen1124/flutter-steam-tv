import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';

final class HomeErrorView extends StatelessWidget {
  const HomeErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(32),
        child: Column(
          mainAxisSize: .min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: StreamTvColors.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: .center),
            const SizedBox(height: 20),
            FilledButton.icon(
              autofocus: true,
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
