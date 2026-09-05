import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_route.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/vertical_player_screen.dart';
import 'package:flutter_steam_tv/features/player/presentation/view_model/player_view_model.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_buffering_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_player/stream_player.dart';

/// The Riverpod-aware half of the portrait player.
///
/// Shares [PlayerViewModel] with the landscape route: the item, the player and the state are
/// identical, and only the presentation differs. A second ViewModel would be a second copy of the
/// same lifetime rules — including the mandatory `close()` — with a second chance to get them wrong.
final class VerticalPlayerRoute extends ConsumerWidget {
  /// Plays [itemId] in the portrait player.
  const VerticalPlayerRoute({required this.itemId, super.key});

  /// The route path, with the catalogue id as its only parameter.
  static const String path = '/player/vertical/:itemId';

  /// Builds the location for [itemId].
  static String locationFor(String itemId) => '/player/vertical/$itemId';

  /// The catalogue id to play.
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerViewModelProvider(itemId));
    final viewModel = ref.read(playerViewModelProvider(itemId).notifier);

    return switch (state) {
      AsyncData(:final value) => VerticalPlayerScreen(
        uiState: value,
        videoSurface: _videoSurface(ref),
        onTogglePlayPause: viewModel.togglePlayPause,
        onToggleLiked: viewModel.toggleLiked,
        onToggleSaved: viewModel.toggleSaved,
        onQualitySelected: viewModel.selectQuality,
        onAudioSelected: viewModel.selectAudio,
        onSubtitlesSelected: viewModel.selectSubtitles,
        onRetry: viewModel.retry,
        onExit: () => _exit(context),
      ),
      AsyncError(:final error) => PlayerStartupError(
        message: _messageFor(error),
        onRetry: () => ref.invalidate(playerViewModelProvider(itemId)),
        onExit: () => _exit(context),
      ),
      _ => const _VerticalPlayerStartup(),
    };
  }

  /// The native surface, cropped to fill the stage.
  ///
  /// `zoom` rather than `fit`: the stage is already the video's own aspect ratio, so cropping only
  /// trims the rounding error — while `fit` would letterbox *inside* the stage and reintroduce the
  /// bars the portrait layout exists to avoid.
  Widget _videoSurface(WidgetRef ref) {
    final controller = ref.watch(playerControllerProvider(itemId)).value;
    if (controller == null) {
      return const ColoredBox(color: StreamTvColors.playerBackground);
    }
    return StreamPlayerView(
      controller: controller,
      resizeMode: StreamPlayerResizeMode.zoom,
    );
  }

  void _exit(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/');
  }

  String _messageFor(Object error) {
    if (error case StateError(:final message)) {
      return message;
    }
    return 'Unable to start playback';
  }
}

final class _VerticalPlayerStartup extends StatelessWidget {
  const _VerticalPlayerStartup();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: StreamTvColors.playerBackground,
    body: Center(child: PlayerBufferingIndicator()),
  );
}
