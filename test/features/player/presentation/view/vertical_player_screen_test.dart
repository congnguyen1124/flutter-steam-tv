import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/vertical_player_screen.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_buffering_indicator.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_error_panel.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_progress_bar.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/vertical_player_stage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_player/stream_player.dart';

/// Drives the portrait player with a remote, against `spec/vertical-player.md`.
void main() {
  String? focused() => FocusManager.instance.primaryFocus?.debugLabel;

  group('base level', () {
    testWidgets('the stage owns focus on entry', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();

      // Nothing to reveal here: unlike landscape, the stage and the panel are both already on
      // screen, so the player starts on the control that matters.
      expect(focused(), 'vertical-player-stage');
    });

    testWidgets('select on the stage toggles playback', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(
        _app(_state(isPlaying: true), onTogglePlayPause: () => toggles++),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      // The stage *is* the play/pause control on this screen.
      expect(toggles, 1);
    });

    testWidgets('right from the stage enters at the first action', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      // Not the title block: the action row is what a viewer reaches for, and the title is one
      // step Up from there.
      expect(focused(), 'vertical-player-like');
    });

    testWidgets('up from the first action reaches the title block', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(focused(), 'vertical-player-title');
    });

    testWidgets('left from the first action returns to the stage', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(focused(), 'vertical-player-stage');
    });

    testWidgets('left from a later action moves within the row', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(focused(), 'vertical-player-save');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // The asymmetry that keeps a viewer from falling out of the panel halfway along the row.
      expect(focused(), 'vertical-player-like');
    });

    testWidgets('left from the stage never reaches the parked anchor', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();

      // `spec/vertical-player.md`: there is nothing to the left of the stage, so Left must do
      // nothing. The parked anchor lives at the screen's leading edge and would otherwise be
      // exactly what directional traversal finds — and it swallows every key it receives.
      for (var press = 0; press < 3; press++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
      }

      expect(focused(), 'vertical-player-stage');
    });
  });

  group('stage chrome', () {
    testWidgets('a paused stage shows the static play glyph', (tester) async {
      await tester.pumpWidget(_app(_state()));
      await tester.pumpAndSettle();

      // With no control row on this surface, a paused short would otherwise look identical to a
      // stalled one.
      expect(find.byType(PlayerBufferingIndicator), findsNothing);
      expect(find.bySemanticsLabel('Play'), findsNothing);
      expect(find.byType(VerticalPlayerStage), findsOneWidget);
    });

    testWidgets('buffering shows the indicator instead', (tester) async {
      await tester.pumpWidget(
        _app(_state(playbackState: StreamPlayerPlaybackState.buffering)),
      );
      await tester.pump();

      expect(find.byType(PlayerBufferingIndicator), findsOneWidget);
    });

    testWidgets('a seekable short shows a progress line', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerProgressBar), findsOneWidget);
    });

    testWidgets('a live item shows none', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true, isLive: true)));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerProgressBar), findsNothing);
    });
  });

  group('sections', () {
    testWidgets('the title block opens metadata, and back returns to the stage', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.text('About'), findsOneWidget);
      // Twice: the panel shows it in full, and the title block still shows its one-line version
      // underneath — the panel covers only the trailing edge, not the whole screen.
      expect(find.text('A short worth watching'), findsNWidgets(2));

      // A system pop, not a key: that is how Back reaches a Flutter TV app, and `PopScope` is the
      // single owner of it on this screen.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Back to the stage, not to the control that opened it: the panel never went away, so the
      // stage is where a viewer expects to land.
      expect(find.text('About'), findsNothing);
      expect(focused(), 'vertical-player-stage');
    });

    testWidgets('a panel is dismissable with left as well as back', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.text('About'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      // Panels slide in beside a stage the viewer can walk back to, so Left is the natural way out.
      expect(find.text('About'), findsNothing);
    });
  });

  group('errors', () {
    testWidgets('a failure replaces the stage and the panel', (tester) async {
      await tester.pumpWidget(
        _app(
          _state(error: const StreamPlayerNoNetworkError(message: 'offline')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlayerErrorPanel), findsOneWidget);
      expect(find.byType(VerticalPlayerStage), findsNothing);
    });
  });
}

Widget _app(PlayerUiState uiState, {VoidCallback? onTogglePlayPause}) =>
    MaterialApp(
      home: VerticalPlayerScreen(
        uiState: uiState,
        videoSurface: const ColoredBox(color: Color(0xFF275D8C)),
        onTogglePlayPause: onTogglePlayPause ?? _noop,
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
    description: 'A short worth watching',
    streamUrl: Uri.parse('https://example.invalid/a.m3u8'),
    isLive: isLive,
  ),
  playerState: StreamPlayerState.initial.copyWith(
    isPlaying: isPlaying,
    playbackState: playbackState,
    position: const Duration(seconds: 20),
    duration: isLive ? Duration.zero : const Duration(minutes: 1),
    error: error,
  ),
  capabilities: StreamPlayerCapabilities.full,
);

void _noop() {}

void _ignoreString(String _) {}
