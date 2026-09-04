import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_screen.dart';
import 'package:flutter_steam_tv/features/player/presentation/view_model/player_view_model.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_buffering_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_player/stream_player.dart';

/// The Riverpod-aware half of the player.
///
/// It knows about providers and navigation; [PlayerScreen] knows about neither. That split is what
/// lets the screen be previewed and widget-tested with no container, no network and no native
/// player.
final class PlayerRoute extends ConsumerWidget {
  /// Plays [itemId].
  const PlayerRoute({required this.itemId, super.key});

  /// The route path, with the catalogue id as its only parameter.
  static const String path = '/player/:itemId';

  /// Builds the location for [itemId].
  static String locationFor(String itemId) => '/player/$itemId';

  /// The catalogue id to play.
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerViewModelProvider(itemId));
    final viewModel = ref.read(playerViewModelProvider(itemId).notifier);

    return switch (state) {
      AsyncData(:final value) => PlayerScreen(
        uiState: value,
        // Built here so the screen never depends on a native player. The surface is the host's
        // decision — a platform view on Android, a texture on Tizen — and this is the one place
        // that difference exists.
        videoSurface: _videoSurface(ref),
        onTogglePlayPause: viewModel.togglePlayPause,
        onSeekForward: viewModel.seekForward,
        onSeekBack: viewModel.seekBack,
        onToggleLiked: viewModel.toggleLiked,
        onToggleSaved: viewModel.toggleSaved,
        onQualitySelected: viewModel.selectQuality,
        onAudioSelected: viewModel.selectAudio,
        onSubtitlesSelected: viewModel.selectSubtitles,
        onRetry: viewModel.retry,
        onExit: () => _exit(context),
      ),
      // A failure here is a catalogue or player-creation failure, not a playback one: playback
      // failures arrive inside the state and are drawn by the screen's own error panel, over the
      // video, with the title still visible.
      AsyncError(:final error) => _PlayerStartupError(
        message: _messageFor(error),
        onRetry: () => ref.invalidate(playerViewModelProvider(itemId)),
        onExit: () => _exit(context),
      ),
      _ => const _PlayerStartup(),
    };
  }

  /// The native surface, or the shutter until the player exists.
  Widget _videoSurface(WidgetRef ref) {
    final controller = ref.watch(playerControllerProvider(itemId)).valueOrNull;
    if (controller == null) {
      return const ColoredBox(color: StreamTvColors.playerBackground);
    }
    return StreamPlayerView(controller: controller);
  }

  void _exit(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    // Reachable when the player is a deep link's first destination, where there is nothing to pop
    // back to and leaving the viewer stranded on a black screen would be the alternative.
    context.go('/');
  }

  String _messageFor(Object error) {
    if (error case StateError(:final message)) {
      return message;
    }
    return 'Unable to start playback';
  }
}

/// Black plus a spinner, matching what the player itself shows while buffering.
///
/// So the hand-off from "starting up" to "buffering the stream" is invisible: the viewer sees one
/// continuous spinner rather than a flash between two different loading treatments.
final class _PlayerStartup extends StatelessWidget {
  const _PlayerStartup();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: StreamTvColors.playerBackground,
    body: Center(child: PlayerBufferingIndicator()),
  );
}

final class _PlayerStartupError extends StatelessWidget {
  const _PlayerStartupError({
    required this.message,
    required this.onRetry,
    required this.onExit,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StreamTvColors.playerBackground,
      body: Padding(
        padding: const .all(48),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              message,
              textAlign: .center,
              style: const TextStyle(
                color: StreamTvColors.playerMutedForeground,
                fontSize: 22,
                fontWeight: .w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: .center,
              children: [
                TextButton(
                  autofocus: true,
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                const SizedBox(width: 12),
                TextButton(onPressed: onExit, child: const Text('Go back')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
