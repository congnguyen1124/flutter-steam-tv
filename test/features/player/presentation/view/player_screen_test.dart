import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/view/player_screen.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_buffering_indicator.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_control_row.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_error_panel.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_seek_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_player/stream_player.dart';

/// Drives the screen with a remote.
///
/// Possible at all because `PlayerScreen` takes its video surface as a widget: there is no native
/// player in this test, no channel, and no plugin — which is exactly why the seam is shaped that
/// way.
void main() {
  group('revealing the chrome', () {
    testWidgets('the controller is hidden until a key is pressed', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));

      expect(find.byType(PlayerControlRow), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(find.byType(PlayerControlRow), findsOneWidget);
    });

    testWidgets('the reveal press does not also activate a control', (
      tester,
    ) async {
      var toggles = 0;
      await tester.pumpWidget(
        _app(_state(isPlaying: true), onTogglePlayPause: () => toggles++),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      // The press that summons the controls is consumed by the surface. Without that, its key-up
      // lands on whichever control just took focus and fires it immediately.
      expect(toggles, 0);
    });

    testWidgets('the play/pause key toggles and reveals in one press', (
      tester,
    ) async {
      var toggles = 0;
      await tester.pumpWidget(
        _app(_state(isPlaying: true), onTogglePlayPause: () => toggles++),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.mediaPlayPause);
      await tester.pumpAndSettle();

      expect(toggles, 1);
      expect(find.byType(PlayerControlRow), findsOneWidget);
    });
  });

  group('seekability', () {
    testWidgets('an on-demand item shows a seek bar', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(find.byType(PlayerSeekBar), findsOneWidget);
    });

    testWidgets('a live item shows none', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true, isLive: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      // A live stream reports no duration, so a progress bar would sit at zero and a seek would
      // have nowhere to land.
      expect(find.byType(PlayerSeekBar), findsNothing);
      expect(find.byType(PlayerControlRow), findsOneWidget);
    });
  });

  group('live streams', () {
    testWidgets('an elapsed-time label stands in for the seek bar', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true, isLive: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      // Not simply nothing, per spec/player.md: the viewer still wants to know how long they have
      // been watching, and an empty slot would let the control row jump the moment a duration
      // arrives.
      expect(find.byType(PlayerSeekBar), findsNothing);
      expect(find.text('1:00'), findsOneWidget);
    });

    testWidgets('rewind and forward are absent', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true, isLive: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(find.text('Rewind'), findsNothing);
      expect(find.text('Forward'), findsNothing);
    });
  });

  group('focus graph', () {
    // Asserted through the focus nodes' debug labels, because that is the only way to name *which*
    // control holds the D-pad. The labels are set by PlayerScreen itself, so they are as stable as
    // the enum they come from.
    String? focusedControl() => FocusManager.instance.primaryFocus?.debugLabel;

    testWidgets('the controller opens on play/pause', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(focusedControl(), 'player-playPause');
    });

    testWidgets('up reaches the seek bar and down returns to the control in use', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(focusedControl(), 'player-progress');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // spec/player.md: Down from the seek bar returns to the control the viewer last used, which
      // before any move is play/pause. Handled by an explicit callback rather than by traversal,
      // because the destination is remembered state.
      expect(focusedControl(), 'player-playPause');
    });

    testWidgets('left and right on the seek bar seek without moving focus', (
      tester,
    ) async {
      var forwards = 0;
      await tester.pumpWidget(
        _app(_state(isPlaying: true), onSeekForward: () => forwards++),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(forwards, 1);
      expect(focusedControl(), 'player-progress');
    });
  });

  group('auto-hide', () {
    testWidgets('the chrome hides itself while playing', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.byType(PlayerControlRow), findsOneWidget);

      await tester.pump(PlayerScreen.controllerAutoHide);
      await tester.pumpAndSettle();

      expect(find.byType(PlayerControlRow), findsNothing);
    });

    testWidgets('a paused player keeps its chrome', (tester) async {
      await tester.pumpWidget(_app(_state()));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      await tester.pump(PlayerScreen.controllerAutoHide * 2);
      await tester.pumpAndSettle();

      // The viewer stopped to look at something. Hiding the controls out from under them is the
      // opposite of helpful.
      expect(find.byType(PlayerControlRow), findsOneWidget);
    });
  });

  group('buffering', () {
    testWidgets('the spinner shows while buffering', (tester) async {
      await tester.pumpWidget(_app(_state(playbackState: .buffering)));

      expect(find.byType(PlayerBufferingIndicator), findsOneWidget);
    });
  });

  group('errors', () {
    testWidgets('a retryable failure offers a retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        _app(
          _state(error: const StreamPlayerNoNetworkError(message: 'offline')),
          onRetry: () => retries++,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlayerErrorPanel), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('a forbidden stream offers none', (tester) async {
      await tester.pumpWidget(
        _app(
          _state(
            error: const StreamPlayerNotEntitledError(message: 'HTTP 403'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Retrying the same request fails identically, so offering the button only invites the viewer
      // to fail twice.
      expect(find.byType(PlayerErrorPanel), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('an error replaces chrome that was already up', (tester) async {
      await tester.pumpWidget(_app(_state(isPlaying: true)));
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.byType(PlayerControlRow), findsOneWidget);

      await tester.pumpWidget(
        _app(
          _state(
            isPlaying: true,
            error: const StreamPlayerNoNetworkError(message: 'offline'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Focus must not be left sitting on a control whose player is dead.
      expect(find.byType(PlayerControlRow), findsNothing);
      expect(find.byType(PlayerErrorPanel), findsOneWidget);
    });
  });
}

Widget _app(
  PlayerUiState uiState, {
  VoidCallback? onTogglePlayPause,
  VoidCallback? onSeekForward,
  VoidCallback? onRetry,
}) => MaterialApp(
  home: PlayerScreen(
    uiState: uiState,
    videoSurface: const ColoredBox(color: Color(0xFF275D8C)),
    onTogglePlayPause: onTogglePlayPause ?? _noop,
    onSeekForward: onSeekForward ?? _noop,
    onSeekBack: _noop,
    onToggleLiked: _noop,
    onToggleSaved: _noop,
    onQualitySelected: _ignoreString,
    onAudioSelected: _ignoreString,
    onSubtitlesSelected: _ignoreString,
    onRetry: onRetry ?? _noop,
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
    streamUrl: Uri.parse('https://example.invalid/a.m3u8'),
    isLive: isLive,
  ),
  playerState: StreamPlayerState.initial.copyWith(
    isPlaying: isPlaying,
    playbackState: playbackState,
    position: const Duration(minutes: 1),
    duration: isLive ? Duration.zero : const Duration(minutes: 10),
    error: error,
  ),
  capabilities: StreamPlayerCapabilities.full,
);

void _noop() {}

void _ignoreString(String _) {}
