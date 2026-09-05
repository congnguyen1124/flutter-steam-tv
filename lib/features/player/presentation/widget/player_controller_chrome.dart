import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_control_row.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_seek_bar.dart';

/// Full-screen controller chrome: a scrim, the title block, and the controls.
///
/// ## Why top-and-bottom rather than one bottom stack
///
/// The title sits in the upper-left where nothing competes with it, and everything interactive
/// collects along the bottom edge — seek bar first, then the control row. That ordering is what
/// makes the vertical D-pad axis mean something: Up from any control is always "go scrub", and
/// there is nothing below the row. Ported from the Compose player's `PlayerController`.
///
/// The scrim is a vertical gradient dark at both ends and clear through the middle, so chrome stays
/// legible over a bright frame without dimming the picture the viewer came for.
final class PlayerControllerChrome extends StatelessWidget {
  /// The chrome for [uiState].
  const PlayerControllerChrome({
    required this.uiState,
    required this.focusNodes,
    required this.entryTarget,
    required this.onTogglePlayPause,
    required this.onSeekForward,
    required this.onSeekBack,
    required this.onToggleLiked,
    required this.onToggleSaved,
    required this.onOpenSettings,
    required this.onSeekBarMoveDown,
    required this.onInteraction,
    super.key,
  });

  static const double _horizontalPadding = 54;
  static const double _topPadding = 44;
  static const double _bottomPadding = 34;
  static const double _titleWidth = 760;

  /// What to render.
  final PlayerUiState uiState;

  /// Owned by the screen.
  final Map<PlayerControlTarget, FocusNode> focusNodes;

  /// Which control claims focus when the chrome appears.
  ///
  /// Resolved by the screen, which remembers the last control used — so closing the settings panel
  /// returns focus to the button that opened it.
  final PlayerControlTarget entryTarget;

  /// Play if paused, pause if playing.
  final VoidCallback onTogglePlayPause;

  /// Seek forward by the configured increment.
  final VoidCallback onSeekForward;

  /// Seek back by the configured increment.
  final VoidCallback onSeekBack;

  /// Toggle the like affordance.
  final VoidCallback onToggleLiked;

  /// Toggle the save affordance.
  final VoidCallback onToggleSaved;

  /// Open the settings panel.
  final VoidCallback onOpenSettings;

  /// Move focus from the seek bar down to the control the viewer last used.
  final VoidCallback onSeekBarMoveDown;

  /// Called on every interaction, so the screen can defer its auto-hide timer.
  final VoidCallback onInteraction;

  @override
  Widget build(BuildContext context) {
    final showSeekBar = uiState.isSeekable;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: .topCenter,
          end: .bottomCenter,
          colors: [
            StreamTvColors.playerScrimTop,
            Colors.transparent,
            Colors.transparent,
            StreamTvColors.playerScrimBottom,
          ],
          stops: [0, 0.42, 0.52, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: _horizontalPadding,
            top: _topPadding,
            width: _titleWidth,
            child: _TitleBlock(uiState: uiState),
          ),
          Positioned(
            left: _horizontalPadding,
            right: _horizontalPadding,
            bottom: _bottomPadding,
            // A traversal group, so Up and Down move between the seek bar and the row without
            // either of them naming the other.
            child: FocusTraversalGroup(
              policy: ReadingOrderTraversalPolicy(),
              child: Column(
                mainAxisSize: .min,
                children: [
                  // A live stream gets an elapsed-time label where the seek bar would be, per
                  // spec/player.md. Not simply nothing: the viewer still wants to know how long
                  // they have been watching, and an empty slot would let the control row jump up
                  // the moment a stream's duration arrives.
                  if (showSeekBar)
                    PlayerSeekBar(
                      uiState: uiState,
                      focusNode: focusNodes[PlayerControlTarget.progress]!,
                      onSeekForward: onSeekForward,
                      onSeekBack: onSeekBack,
                      onTogglePlayPause: onTogglePlayPause,
                      onMoveDown: onSeekBarMoveDown,
                      onInteraction: onInteraction,
                      autofocus: entryTarget == PlayerControlTarget.progress,
                    )
                  else
                    _ElapsedLabel(position: uiState.position),
                  const SizedBox(height: 4),
                  PlayerControlRow(
                    uiState: uiState,
                    focusNodes: focusNodes,
                    onTogglePlayPause: onTogglePlayPause,
                    onSeekForward: onSeekForward,
                    onSeekBack: onSeekBack,
                    onToggleLiked: onToggleLiked,
                    onToggleSaved: onToggleSaved,
                    onOpenSettings: onOpenSettings,
                    onInteraction: onInteraction,
                    autofocusTarget: entryTarget,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The live stand-in for the seek bar: elapsed time only, and not focusable.
final class _ElapsedLabel extends StatelessWidget {
  const _ElapsedLabel({required this.position});

  final Duration position;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: PlayerSeekBar.controlHeight,
    width: double.infinity,
    child: Align(
      alignment: .centerLeft,
      child: Text(
        formatPlayerClock(position),
        style: const TextStyle(
          color: StreamTvColors.playerMutedForeground,
          fontSize: 12,
          fontWeight: .w500,
        ),
      ),
    ),
  );
}

final class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.uiState});

  final PlayerUiState uiState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            if (uiState.isLive) ...[
              const _LiveBadge(),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                uiState.item.title,
                // Two, per spec/player.md: a TV title is often long enough that one line ellipsises
                // away the part that identifies the episode.
                maxLines: 2,
                overflow: .ellipsis,
                style: const TextStyle(
                  color: StreamTvColors.playerForeground,
                  fontSize: 30,
                  height: 38 / 30,
                  fontWeight: .w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          uiState.item.description,
          maxLines: 2,
          overflow: .ellipsis,
          style: const TextStyle(
            color: StreamTvColors.playerMutedForeground,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

final class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: StreamTvColors.live,
      borderRadius: .circular(4),
    ),
    child: const Padding(
      padding: .symmetric(horizontal: 8, vertical: 2),
      child: Text(
        'LIVE',
        style: TextStyle(
          color: StreamTvColors.playerForeground,
          fontSize: 12,
          fontWeight: .w700,
        ),
      ),
    ),
  );
}
