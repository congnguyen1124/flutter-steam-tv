import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_icon_button.dart';

/// The control row, below the seek bar.
///
/// ## Why a Stack and not a Row with spacers
///
/// The transport group has to sit dead centre on the panel regardless of how wide the trailing
/// cluster is. A row with flexible spacers centres the *gap* between the clusters instead, so the
/// play button drifts as soon as the settings button appears or disappears. Ported from the Compose
/// player, including that reasoning.
///
/// Which controls exist is a function of state, not of configuration: rewind and forward only for
/// seekable content, settings only when the host has something to offer.
final class PlayerControlRow extends StatelessWidget {
  /// The control row for [uiState].
  const PlayerControlRow({
    required this.uiState,
    required this.focusNodes,
    required this.onTogglePlayPause,
    required this.onSeekForward,
    required this.onSeekBack,
    required this.onToggleLiked,
    required this.onToggleSaved,
    required this.onOpenSettings,
    required this.onInteraction,
    this.autofocusTarget,
    super.key,
  });

  /// Tall enough to hold a 44dp button plus the caption that appears under the focused one.
  static const double height = 84;

  /// What to render.
  final PlayerUiState uiState;

  /// Owned by the screen, so focus survives the chrome being rebuilt.
  final Map<PlayerControlTarget, FocusNode> focusNodes;

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

  /// Called on every activation, so the screen can defer its auto-hide timer.
  final VoidCallback onInteraction;

  /// Which control claims focus when the row first appears, or null for none.
  final PlayerControlTarget? autofocusTarget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: .center,
            child: _TransportCluster(
              uiState: uiState,
              focusNodes: focusNodes,
              autofocusTarget: autofocusTarget,
              onTogglePlayPause: _guarded(onTogglePlayPause),
              onSeekForward: _guarded(onSeekForward),
              onSeekBack: _guarded(onSeekBack),
            ),
          ),
          Align(
            alignment: .centerRight,
            child: _ActionCluster(
              uiState: uiState,
              focusNodes: focusNodes,
              autofocusTarget: autofocusTarget,
              onToggleLiked: _guarded(onToggleLiked),
              onToggleSaved: _guarded(onToggleSaved),
              onOpenSettings: _guarded(onOpenSettings),
            ),
          ),
        ],
      ),
    );
  }

  /// Reports the interaction before running the action, so every press defers the auto-hide.
  VoidCallback _guarded(VoidCallback action) => () {
    onInteraction();
    action();
  };
}

/// Rewind, play/pause, forward.
///
/// The Compose reference puts previous/next episode here; with no playlist to step through, the same
/// three slots carry the seek increments instead — so the shape is familiar and every button does
/// something.
final class _TransportCluster extends StatelessWidget {
  const _TransportCluster({
    required this.uiState,
    required this.focusNodes,
    required this.autofocusTarget,
    required this.onTogglePlayPause,
    required this.onSeekForward,
    required this.onSeekBack,
  });

  final PlayerUiState uiState;
  final Map<PlayerControlTarget, FocusNode> focusNodes;
  final PlayerControlTarget? autofocusTarget;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        if (uiState.isSeekable) ...[
          PlayerIconButton(
            iconAsset: AppAssets.replay10Icon,
            semanticLabel: 'Rewind',
            label: 'Rewind',
            onPressed: onSeekBack,
            focusNode: focusNodes[PlayerControlTarget.rewind]!,
            autofocus: autofocusTarget == PlayerControlTarget.rewind,
          ),
          const SizedBox(width: 14),
        ],
        PlayerIconButton(
          iconAsset: uiState.isPlaying ? AppAssets.pauseIcon : AppAssets.playIcon,
          semanticLabel: uiState.isPlaying ? 'Pause' : 'Play',
          onPressed: onTogglePlayPause,
          focusNode: focusNodes[PlayerControlTarget.playPause]!,
          size: PlayerIconButton.primarySize,
          iconSize: PlayerIconButton.primaryIconSize,
          autofocus: autofocusTarget == PlayerControlTarget.playPause,
        ),
        if (uiState.isSeekable) ...[
          const SizedBox(width: 14),
          PlayerIconButton(
            iconAsset: AppAssets.forward10Icon,
            semanticLabel: 'Forward',
            label: 'Forward',
            onPressed: onSeekForward,
            focusNode: focusNodes[PlayerControlTarget.forward]!,
            autofocus: autofocusTarget == PlayerControlTarget.forward,
          ),
        ],
      ],
    );
  }
}

/// Like and save on one shared pill, then settings on its own circle.
///
/// The shared pill is drawn behind the buttons rather than around them, and the buttons are
/// transparent until focused — so focus inverts one circle inside a pill that never moves.
final class _ActionCluster extends StatelessWidget {
  const _ActionCluster({
    required this.uiState,
    required this.focusNodes,
    required this.autofocusTarget,
    required this.onToggleLiked,
    required this.onToggleSaved,
    required this.onOpenSettings,
  });

  static const double _pillHeight = 44;

  final PlayerUiState uiState;
  final Map<PlayerControlTarget, FocusNode> focusNodes;
  final PlayerControlTarget? autofocusTarget;
  final VoidCallback onToggleLiked;
  final VoidCallback onToggleSaved;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: StreamTvColors.playerControlIdle,
            borderRadius: .circular(_pillHeight / 2),
          ),
          child: Padding(
            padding: const .symmetric(horizontal: 2),
            child: Row(
              mainAxisSize: .min,
              children: [
                PlayerIconButton(
                  iconAsset: uiState.isLiked
                      ? AppAssets.heartIcon
                      : AppAssets.heartOutlineIcon,
                  semanticLabel: 'Like',
                  label: 'Like',
                  onPressed: onToggleLiked,
                  focusNode: focusNodes[PlayerControlTarget.like]!,
                  idleColor: Colors.transparent,
                  autofocus: autofocusTarget == PlayerControlTarget.like,
                ),
                PlayerIconButton(
                  iconAsset: uiState.isSaved
                      ? AppAssets.bookmarkIcon
                      : AppAssets.bookmarkOutlineIcon,
                  semanticLabel: 'Save',
                  label: 'Save',
                  onPressed: onToggleSaved,
                  focusNode: focusNodes[PlayerControlTarget.save]!,
                  idleColor: Colors.transparent,
                  autofocus: autofocusTarget == PlayerControlTarget.save,
                ),
              ],
            ),
          ),
        ),
        // Only when the host has renditions to offer. On Tizen `capabilities` reports no track
        // selection, so this never appears rather than opening an empty panel.
        if (uiState.settings.isAvailable) ...[
          const SizedBox(width: 8),
          PlayerIconButton(
            iconAsset: AppAssets.settingsIcon,
            semanticLabel: 'Settings',
            label: 'Settings',
            onPressed: onOpenSettings,
            focusNode: focusNodes[PlayerControlTarget.settings]!,
            autofocus: autofocusTarget == PlayerControlTarget.settings,
          ),
        ],
      ],
    );
  }
}
