import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/vertical_player_screen.dart';
import 'package:stream_player/stream_player.dart';

/// Deterministic previews of the portrait player.
///
/// The stage's video is a flat colour, not a player: previews must not touch a native plugin, and
/// the screen takes its surface as a widget precisely so this is possible. Everything else — the
/// ambient gradient, the stage chrome, the interaction panel — is real.

@Preview(
  name: 'Vertical player - playing',
  group: 'Vertical player',
  size: Size(1280, 720),
)
Widget verticalPlayerPlayingPreview() => _preview(_state(isPlaying: true));

@Preview(
  name: 'Vertical player - paused',
  group: 'Vertical player',
  size: Size(1280, 720),
)
Widget verticalPlayerPausedPreview() => _preview(_state());

@Preview(
  name: 'Vertical player - buffering',
  group: 'Vertical player',
  size: Size(1280, 720),
)
Widget verticalPlayerBufferingPreview() =>
    _preview(_state(playbackState: .buffering));

@Preview(
  name: 'Vertical player - live',
  group: 'Vertical player',
  size: Size(1280, 720),
)
Widget verticalPlayerLivePreview() =>
    _preview(_state(isPlaying: true, isLive: true));

@Preview(
  name: 'Vertical player - error',
  group: 'Vertical player',
  size: Size(1280, 720),
)
Widget verticalPlayerErrorPreview() => _preview(
  _state(error: const StreamPlayerNoNetworkError(message: 'preview')),
);

@Preview(
  name: 'Vertical player - 1080p',
  group: 'Vertical player',
  size: Size(1920, 1080),
)
Widget verticalPlayerFullHdPreview() => _preview(_state(isPlaying: true));

Widget _preview(PlayerUiState uiState) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: StreamTvTheme.dark,
  home: VerticalPlayerScreen(
    uiState: uiState,
    videoSurface: const ColoredBox(color: StreamTvColors.green),
    onTogglePlayPause: _noop,
    onToggleLiked: _noop,
    onToggleSaved: _noop,
    onQualitySelected: _ignoreString,
    onAudioSelected: _ignoreString,
    onSubtitlesSelected: _ignoreString,
    onRetry: _noop,
    onExit: _noop,
  ),
);

PlayerUiState _state({
  bool isPlaying = false,
  bool isLive = false,
  StreamPlayerPlaybackState playbackState = StreamPlayerPlaybackState.ready,
  StreamPlayerError? error,
}) => PlayerUiState(
  item: PlaybackItem(
    id: 'short-cricket-focus',
    title: 'Before the strike',
    description:
        'A cricket player finds complete focus just before the game begins',
    streamUrl: Uri.parse('https://example.invalid/preview.m3u8'),
    isLive: isLive,
  ),
  playerState: StreamPlayerState.initial.copyWith(
    isPlaying: isPlaying,
    playbackState: playbackState,
    position: const Duration(seconds: 18),
    duration: isLive ? Duration.zero : const Duration(seconds: 45),
    bufferedPosition: isLive ? Duration.zero : const Duration(seconds: 30),
    videoTracks: _previewVideoTracks,
    error: error,
  ),
  capabilities: StreamPlayerCapabilities.full,
);

const _previewVideoTracks = [
  StreamPlayerVideoTrack(
    id: '1080',
    width: 1080,
    height: 1920,
    bitrate: 6000000,
    isSelected: true,
  ),
  StreamPlayerVideoTrack(
    id: '720',
    width: 720,
    height: 1280,
    bitrate: 3000000,
    isSelected: false,
  ),
];

void _noop() {}

void _ignoreString(String _) {}
