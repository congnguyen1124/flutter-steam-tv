import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_screen.dart';
import 'package:stream_player/stream_player.dart';

/// Deterministic previews of every state the player screen can be in.
///
/// The surface is a flat colour, not a player: previews must not touch a native plugin, and the
/// screen takes its surface as a widget precisely so this is possible. Everything else — chrome,
/// spinner, settings, error — is real.

@Preview(name: 'Player - playing', group: 'Player', size: Size(1280, 720))
Widget playerPlayingPreview() => _preview(_state(isPlaying: true));

@Preview(name: 'Player - buffering', group: 'Player', size: Size(1280, 720))
Widget playerBufferingPreview() =>
    _preview(_state(playbackState: .buffering));

@Preview(name: 'Player - live', group: 'Player', size: Size(1280, 720))
Widget playerLivePreview() => _preview(_state(isPlaying: true, isLive: true));

@Preview(name: 'Player - error', group: 'Player', size: Size(1280, 720))
Widget playerErrorPreview() => _preview(
  _state(
    error: const StreamPlayerNoNetworkError(message: 'preview'),
  ),
);

@Preview(name: 'Player - playing 1080p', group: 'Player', size: Size(1920, 1080))
Widget playerPlayingFullHdPreview() => _preview(_state(isPlaying: true));

Widget _preview(PlayerUiState uiState) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: StreamTvTheme.dark,
  home: PlayerScreen(
    uiState: uiState,
    videoSurface: const ColoredBox(color: StreamTvColors.blue),
    onTogglePlayPause: _noop,
    onSeekForward: _noop,
    onSeekBack: _noop,
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
    id: 'wild-frontier',
    title: 'Wild Frontier',
    description: 'A journey into untouched landscapes',
    streamUrl: Uri.parse('https://example.invalid/preview.m3u8'),
    isLive: isLive,
  ),
  playerState: StreamPlayerState.initial.copyWith(
    isPlaying: isPlaying,
    playbackState: playbackState,
    position: const Duration(minutes: 12, seconds: 34),
    duration: isLive ? Duration.zero : const Duration(minutes: 48),
    bufferedPosition: isLive ? Duration.zero : const Duration(minutes: 19),
    videoTracks: _previewVideoTracks,
    audioTracks: _previewAudioTracks,
    textTracks: _previewTextTracks,
    error: error,
  ),
  capabilities: StreamPlayerCapabilities.full,
);

const _previewVideoTracks = [
  StreamPlayerVideoTrack(
    id: '1080',
    width: 1920,
    height: 1080,
    bitrate: 6000000,
    isSelected: true,
  ),
  StreamPlayerVideoTrack(
    id: '720',
    width: 1280,
    height: 720,
    bitrate: 3000000,
    isSelected: false,
  ),
];

const _previewAudioTracks = [
  StreamPlayerAudioTrack(
    id: 'en',
    language: 'en',
    label: 'English',
    isDefaultSelected: true,
    isSelected: true,
  ),
  StreamPlayerAudioTrack(
    id: 'vi',
    language: 'vi',
    label: 'Vietnamese',
    isDefaultSelected: false,
    isSelected: false,
  ),
];

const _previewTextTracks = [
  StreamPlayerTextTrack(id: 'en', language: 'en', label: 'English', isSelected: false),
];

void _noop() {}

void _ignoreString(String _) {}
