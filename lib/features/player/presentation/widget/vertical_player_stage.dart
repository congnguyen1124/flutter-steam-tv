import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_buffering_indicator.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_progress_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The 9:16 portrait stage: the video, its chrome, and the focus target that controls playback.
///
/// ## Why the stage is focusable
///
/// The landscape player hides a transient control row behind a passive surface. This screen has no
/// control row at all, so the stage itself has to be the play/pause control — Select on it toggles
/// playback. That is why it takes a focus border rather than being a plain box.
///
/// ## Why the border fades instead of staying bright
///
/// A 6-unit white border around a portrait video is loud, and on this screen the stage holds focus
/// for as long as the viewer is watching — which is most of the session. Keeping it at full
/// strength would frame every short in a white box.
///
/// So it announces focus and then gets out of the way: bright for [_focusedBorderHold], then a
/// [_focusedBorderFade]-long fade down to a faint outline that still says "this is where the D-pad
/// is". A Select press restarts that cycle, because a press is the moment the viewer wants
/// confirmation they were aiming at the right thing. Ported from OttClouds'
/// `VerticalPlayerFocusableSurface`, including the timings.
///
/// ## Why the paused glyph is state, not an animation
///
/// With no transport controls on this surface, a paused short looks exactly like a stalled one. The
/// glyph is on screen for precisely as long as playback is paused — not as a flash acknowledging
/// the press — and it is not focusable, because the stage behind it already owns the press.
final class VerticalPlayerStage extends StatefulWidget {
  /// The stage for [uiState], showing [videoSurface].
  const VerticalPlayerStage({
    required this.uiState,
    required this.videoSurface,
    required this.focusNode,
    required this.canRequestFocus,
    required this.onTogglePlayPause,
    required this.onMoveToPanel,
    super.key,
  });

  /// Portrait aspect ratio. The stage is sized from the panel height, not from the video.
  static const double aspectRatio = 9 / 16;

  /// Breathing room above and below the stage.
  ///
  /// Deliberately small: the stage is meant to be as tall as the panel allows, so the portrait
  /// frame reads as the subject of the screen rather than as a thumbnail floating in a gradient.
  static const double verticalPadding = 4;

  /// Corner radius of the stage, and the reference for the focus border's own radius.
  static const double cornerRadius = 16;

  /// How far the focus border sits inside the stage edge.
  static const double focusBorderInset = 2;

  /// Stroke width of the focus border.
  static const double focusBorderWidth = 6;

  static const Duration _focusedBorderHold = Duration(seconds: 2);
  static const Duration _focusedBorderFade = Duration(seconds: 1);

  /// What to render.
  final PlayerUiState uiState;

  /// The native video surface, already cropped to fill by the caller.
  final Widget videoSurface;

  /// Owned by the screen.
  final FocusNode focusNode;

  /// Whether the stage may take focus — false while a panel is open or animating.
  final bool canRequestFocus;

  /// Select, or the play/pause key.
  final VoidCallback onTogglePlayPause;

  /// Right, into the interaction panel.
  final VoidCallback onMoveToPanel;

  @override
  State<VerticalPlayerStage> createState() => _VerticalPlayerStageState();
}

final class _VerticalPlayerStageState extends State<VerticalPlayerStage> {
  bool _hasFocus = false;
  bool _hasHeldFocus = false;
  Timer? _holdTimer;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = widget.uiState;

    return Focus(
      focusNode: widget.focusNode,
      canRequestFocus: widget.canRequestFocus,
      onFocusChange: _onFocusChange,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                VerticalPlayerStage.cornerRadius,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: StreamTvColors.playerBackground),
                  widget.videoSurface,
                  if (uiState.isBuffering)
                    const Center(child: PlayerBufferingIndicator())
                  else if (!uiState.isPlaying)
                    const Center(child: _PausedBadge()),
                  if (uiState.isSeekable)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _StageProgress(uiState: uiState),
                    ),
                ],
              ),
            ),
            // Drawn over the video rather than around it, so gaining focus never resizes the frame.
            // Mounted only while focused: remounting is what restarts the fade from full strength
            // when the viewer comes back to the stage.
            if (_hasFocus)
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(
                    VerticalPlayerStage.focusBorderInset,
                  ),
                  child: AnimatedContainer(
                    duration: VerticalPlayerStage._focusedBorderFade,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        VerticalPlayerStage.cornerRadius -
                            VerticalPlayerStage.focusBorderInset,
                      ),
                      border: Border.all(
                        color: _hasHeldFocus
                            ? StreamTvColors.playerFocusBorderSoftened
                            : StreamTvColors.playerForeground,
                        width: VerticalPlayerStage.focusBorderWidth,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onFocusChange(bool hasFocus) {
    setState(() => _hasFocus = hasFocus);
    if (hasFocus) {
      _restartBorderHold();
    } else {
      _holdTimer?.cancel();
      _hasHeldFocus = false;
    }
  }

  /// Brightens the border and starts the countdown to softening it again.
  void _restartBorderHold() {
    _holdTimer?.cancel();
    setState(() => _hasHeldFocus = false);
    _holdTimer = Timer(VerticalPlayerStage._focusedBorderHold, () {
      if (mounted) {
        setState(() => _hasHeldFocus = true);
      }
    });
  }

  void _togglePlayPause() {
    if (_hasFocus) {
      _restartBorderHold();
    }
    widget.onTogglePlayPause();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.mediaPlayPause:
        _togglePlayPause();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowRight:
        widget.onMoveToPanel();
        return KeyEventResult.handled;

      // Up, Down and Left are consumed rather than ignored. There is nothing above, below or to the
      // left of the stage, and letting them fall through to directional traversal would send focus
      // into the panel from the wrong edge — which the spec's focus graph explicitly forbids.
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowLeft:
        return KeyEventResult.handled;

      case _:
        return KeyEventResult.ignored;
    }
  }
}

/// The static play glyph shown while paused.
final class _PausedBadge extends StatelessWidget {
  const _PausedBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: StreamTvColors.playerScrimTop,
      ),
      child: SizedBox.square(
        dimension: 60,
        child: Center(
          child: SvgPicture.asset(
            AppAssets.playIcon,
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              StreamTvColors.playerForeground,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

/// A non-interactive progress line inside the bottom of the stage.
///
/// No thumb and no time labels: this surface offers no scrubbing, and a thumb would advertise an
/// affordance that does not exist here. The scrim exists so the line stays legible over a bright
/// frame without dimming the whole stage.
final class _StageProgress extends StatelessWidget {
  const _StageProgress({required this.uiState});

  final PlayerUiState uiState;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, StreamTvColors.playerScrimBottom],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
        child: PlayerProgressBar(
          progressFraction: uiState.progressFraction,
          bufferedFraction: uiState.bufferedFraction,
        ),
      ),
    );
  }
}
