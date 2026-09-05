import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_progress_bar.dart';

/// The seek bar: two time labels above a track with a thumb.
///
/// ## One focus target, not three
///
/// The whole bar takes focus and Left/Right seek in place, rather than the bar being a row of
/// rewind and forward buttons. That is what a remote makes natural — the viewer holds a direction
/// and the playhead moves — and it is what the Compose player does.
///
/// Left and Right are consumed here; Up and Down are deliberately **not**, so Flutter's directional
/// traversal moves focus to the control row below without this widget having to know what is there.
final class PlayerSeekBar extends StatefulWidget {
  /// A focusable seek bar for [uiState].
  const PlayerSeekBar({
    required this.uiState,
    required this.focusNode,
    required this.onSeekForward,
    required this.onSeekBack,
    required this.onTogglePlayPause,
    required this.onMoveDown,
    required this.onInteraction,
    this.autofocus = false,
    super.key,
  });

  /// Overall control height, so the row above the track has somewhere to sit.
  static const double controlHeight = 40;

  /// What to render.
  final PlayerUiState uiState;

  /// Owned by the screen.
  final FocusNode focusNode;

  /// Seek forward by the configured increment.
  final VoidCallback onSeekForward;

  /// Seek back by the configured increment.
  final VoidCallback onSeekBack;

  /// Toggle playback — Select on the bar itself.
  final VoidCallback onTogglePlayPause;

  /// Move focus down to the control the viewer last used.
  ///
  /// A call rather than a `focusProperties.down` target, because the destination is remembered
  /// state, not a fixed widget — `spec/player.md` requires Down to land on the last-used control,
  /// and Flutter's own focus restoration cannot serve it: this row is left and re-entered by direct
  /// focus requests, which bypass the search-enter and search-exit hooks that restoration keys off.
  final VoidCallback onMoveDown;

  /// Called on every key this widget consumes, so the screen can defer its auto-hide timer.
  final VoidCallback onInteraction;

  /// Whether this bar claims focus when it first appears.
  final bool autofocus;

  @override
  State<PlayerSeekBar> createState() => _PlayerSeekBarState();
}

final class _PlayerSeekBarState extends State<PlayerSeekBar> {
  static const double _thumbFocused = 14;
  static const double _thumbIdle = 10;
  static const double _labelRowHeight = 16;
  static const double _labelToTrackGap = 4;

  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      onKeyEvent: _onKeyEvent,
      child: SizedBox(
        height: PlayerSeekBar.controlHeight,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            // Elapsed and total sit above the track: below it they collide with the control row,
            // and the reference layout reads the same way — time first, then the bar it describes.
            //
            // Height pinned so the column adds up to exactly `controlHeight` (16 + 4 + 20). Letting
            // the row size itself to the text made the total depend on the font's line metrics,
            // which overflowed the box by a pixel with Roboto.
            SizedBox(
              height: _labelRowHeight,
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  _TimeLabel(text: formatPlayerClock(widget.uiState.position)),
                  _TimeLabel(text: formatPlayerClock(widget.uiState.duration)),
                ],
              ),
            ),
            const SizedBox(height: _labelToTrackGap),
            _SeekTrack(
              progressFraction: widget.uiState.progressFraction,
              bufferedFraction: widget.uiState.bufferedFraction,
              thumbSize: _hasFocus ? _thumbFocused : _thumbIdle,
            ),
          ],
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return .ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.mediaRewind:
        widget.onInteraction();
        widget.onSeekBack();
        return .handled;

      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.mediaFastForward:
        widget.onInteraction();
        widget.onSeekForward();
        return .handled;

      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.mediaPlayPause:
        widget.onInteraction();
        widget.onTogglePlayPause();
        return .handled;

      case LogicalKeyboardKey.arrowDown:
        widget.onInteraction();
        widget.onMoveDown();
        return .handled;

      // Up falls through on purpose, so directional traversal leaves the chrome the way it came in.
      case _:
        return .ignored;
    }
  }
}

final class _SeekTrack extends StatelessWidget {
  const _SeekTrack({
    required this.progressFraction,
    required this.bufferedFraction,
    required this.thumbSize,
  });

  final double progressFraction;
  final double bufferedFraction;
  final double thumbSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // `.toDouble()` because `num.clamp` is typed to return `num`, and `left:` wants a double.
        final travel = (constraints.maxWidth - thumbSize)
            .clamp(0.0, double.infinity)
            .toDouble();
        return SizedBox(
          height: 20,
          child: Stack(
            alignment: .centerLeft,
            children: [
              PlayerProgressBar(
                progressFraction: progressFraction,
                bufferedFraction: bufferedFraction,
              ),
              // Animated so a focus change reads as the bar becoming interactive rather than as
              // the thumb jumping.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 140),
                left: travel * progressFraction,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: thumbSize,
                  height: thumbSize,
                  decoration: const BoxDecoration(
                    shape: .circle,
                    color: StreamTvColors.playerForeground,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: StreamTvColors.playerMutedForeground,
      fontSize: 12,
      // Pinned, so the label occupies 14.4px whatever the font's own line metrics say — the row
      // above reserves 16 and must not be overflowed by a font swap.
      height: 1.2,
      fontWeight: .w500,
    ),
  );
}
