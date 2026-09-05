import 'dart:async';

import 'package:flutter_steam_tv/features/player/player_providers.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stream_player/stream_player.dart';

part 'player_view_model.g.dart';

/// Owns the native player for one item.
///
/// Separate from [PlayerViewModel] because the two have different lifetimes and different
/// consumers: the video surface needs the controller object itself, while the screen needs a state
/// snapshot. Keeping them apart also means a rebuild of the screen cannot take the player down
/// with it.
///
/// Auto-disposed, and [Ref.onDispose] closes the player. That is not optional — a leaked player
/// holds a hardware decoder, and on most TVs the third or fourth leaked decoder is where playback
/// stops being able to start at all. Navigating away disposes this provider, which releases it.
@riverpod
Future<StreamPlayerController> playerController(Ref ref, String itemId) async {
  final controller = await StreamPlayerController.create();
  ref.onDispose(() => unawaited(controller.close()));
  return controller;
}

/// Drives the player screen.
///
/// Resolves the item, starts playback, and republishes the player's snapshot as [PlayerUiState].
/// Every action is a one-line forward to the controller: the screen has no playback logic, and
/// neither does this class — that all lives in the native host behind `stream_player`.
@riverpod
final class PlayerViewModel extends _$PlayerViewModel {
  @override
  Future<PlayerUiState> build(String itemId) async {
    final item = await ref
        .watch(playbackRepositoryProvider)
        .getPlaybackItem(itemId);
    final controller = await ref.watch(playerControllerProvider(itemId).future);

    final subscription = controller.states.listen(_onPlayerState);
    ref.onDispose(() => unawaited(subscription.cancel()));

    // Not awaited: `loadAndPlay` completes when the host has accepted the commands, not when the
    // first frame arrives. Awaiting it would hold this provider in `AsyncLoading` past the point
    // where the screen could already be rendering the surface and a spinner.
    unawaited(controller.loadAndPlay(item.streamUrl));

    return PlayerUiState(
      item: item,
      playerState: controller.state,
      capabilities: controller.capabilities,
    );
  }

  /// Plays if paused, pauses if playing.
  ///
  /// A live stream resumes at the live edge instead of where the viewer paused, because resuming
  /// behind the broadcast leaves them with no way back to it.
  Future<void> togglePlayPause() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final controller = await _controller();
    await (current.isLive
        ? controller.togglePlayPauseAtDefaultPosition()
        : controller.togglePlayPause());
  }

  /// Seeks forward by the configured increment.
  Future<void> seekForward() async => (await _controller()).seekForward();

  /// Seeks back by the configured increment.
  Future<void> seekBack() async => (await _controller()).seekBack();

  /// Re-prepares after a failure, and plays.
  Future<void> retry() async => (await _controller()).retry();

  /// Selects a video rendition, or `StreamPlayerVideoTrack.autoId`.
  Future<void> selectQuality(String trackId) async =>
      (await _controller()).selectVideoTrack(trackId);

  /// Selects an audio rendition.
  Future<void> selectAudio(String trackId) async =>
      (await _controller()).selectAudioTrack(trackId);

  /// Selects a subtitle rendition, or `StreamPlayerTextTrack.offId`.
  Future<void> selectSubtitles(String trackId) async =>
      (await _controller()).selectTextTrack(trackId);

  /// Toggles the like affordance. Screen-local until there is a watchlist API.
  void toggleLiked() {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = .data(current.copyWith(isLiked: !current.isLiked));
  }

  /// Toggles the save affordance. Screen-local until there is a watchlist API.
  void toggleSaved() {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = .data(current.copyWith(isSaved: !current.isSaved));
  }

  Future<StreamPlayerController> _controller() =>
      ref.read(playerControllerProvider(itemId).future);

  void _onPlayerState(StreamPlayerState playerState) {
    final current = state.value;
    if (current == null) {
      // The very first snapshots can land while `build` is still resolving the item. Dropping them
      // is safe: `build` seeds from `controller.state`, which is already current by then.
      return;
    }
    state = .data(current.copyWith(playerState: playerState));
  }
}
