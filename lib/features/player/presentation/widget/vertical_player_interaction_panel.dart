import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/assets/app_assets.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_icon_button.dart';

/// The portrait player's trailing panel: the title block over the action row.
///
/// ## Why the title is the metadata entry point
///
/// The landscape player reaches metadata through a `Description` pill because its chrome is a row
/// of controls with no room for prose. Here the title is already on screen and already the largest
/// thing in the panel, so making it the button removes a control instead of adding one.
///
/// ## The asymmetric Left
///
/// Left from the title block and from the **first** action returns to the stage; Left from a later
/// action moves within the row. The stage is the only thing to the left of this panel, so only the
/// panel's leading edge should reach it — otherwise a viewer walking left along the row would fall
/// out of the panel halfway.
final class VerticalPlayerInteractionPanel extends StatelessWidget {
  /// The panel for [uiState].
  const VerticalPlayerInteractionPanel({
    required this.uiState,
    required this.focusNodes,
    required this.canRequestFocus,
    required this.onOpenMetadata,
    required this.onOpenSettings,
    required this.onToggleLiked,
    required this.onToggleSaved,
    required this.onMoveToStage,
    super.key,
  });

  /// Smallest useful panel width, for panels whose stage leaves little room.
  static const double minWidth = 300;

  /// What to render.
  final PlayerUiState uiState;

  /// Owned by the screen, so focus survives a panel opening over this one.
  final Map<VerticalPlayerControlTarget, FocusNode> focusNodes;

  /// Whether the panel may take focus — false while a section is open or animating.
  final bool canRequestFocus;

  /// Open the metadata panel.
  final VoidCallback onOpenMetadata;

  /// Open the settings panel.
  final VoidCallback onOpenSettings;

  /// Toggle the like affordance.
  final VoidCallback onToggleLiked;

  /// Toggle the save affordance.
  final VoidCallback onToggleSaved;

  /// Left from the panel's leading edge.
  final VoidCallback onMoveToStage;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      excluding: !canRequestFocus,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 32, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleBlock(
              uiState: uiState,
              focusNode: focusNodes[VerticalPlayerControlTarget.title]!,
              onPressed: onOpenMetadata,
              onMoveToStage: onMoveToStage,
              onMoveDown: () =>
                  focusNodes[VerticalPlayerControlTarget.like]?.requestFocus(),
            ),
            const SizedBox(height: 18),
            _ActionRow(
              uiState: uiState,
              focusNodes: focusNodes,
              onToggleLiked: onToggleLiked,
              onToggleSaved: onToggleSaved,
              onOpenSettings: onOpenSettings,
              onMoveToStage: onMoveToStage,
              onMoveUp: () =>
                  focusNodes[VerticalPlayerControlTarget.title]?.requestFocus(),
            ),
          ],
        ),
      ),
    );
  }
}

final class _TitleBlock extends StatefulWidget {
  const _TitleBlock({
    required this.uiState,
    required this.focusNode,
    required this.onPressed,
    required this.onMoveToStage,
    required this.onMoveDown,
  });

  final PlayerUiState uiState;
  final FocusNode focusNode;
  final VoidCallback onPressed;
  final VoidCallback onMoveToStage;
  final VoidCallback onMoveDown;

  @override
  State<_TitleBlock> createState() => _TitleBlockState();
}

final class _TitleBlockState extends State<_TitleBlock> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final uiState = widget.uiState;

    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _hasFocus
                ? StreamTvColors.playerControlIdle
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (uiState.isLive) ...[
                      const _LiveBadge(),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        uiState.item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: StreamTvColors.playerMutedForeground,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  uiState.item.title,
                  // Two, per spec: a TV title is often long enough that one line ellipsises away
                  // the part identifying the episode.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: StreamTvColors.playerForeground,
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        widget.onPressed();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowLeft:
        widget.onMoveToStage();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowDown:
        widget.onMoveDown();
        return KeyEventResult.handled;

      case _:
        return KeyEventResult.ignored;
    }
  }
}

final class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.uiState,
    required this.focusNodes,
    required this.onToggleLiked,
    required this.onToggleSaved,
    required this.onOpenSettings,
    required this.onMoveToStage,
    required this.onMoveUp,
  });

  final PlayerUiState uiState;
  final Map<VerticalPlayerControlTarget, FocusNode> focusNodes;
  final VoidCallback onToggleLiked;
  final VoidCallback onToggleSaved;
  final VoidCallback onOpenSettings;
  final VoidCallback onMoveToStage;
  final VoidCallback onMoveUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          target: VerticalPlayerControlTarget.like,
          iconAsset: uiState.isLiked
              ? AppAssets.heartIcon
              : AppAssets.heartOutlineIcon,
          label: 'Like',
          focusNodes: focusNodes,
          onPressed: onToggleLiked,
          // Only the leading action reaches the stage; the rest move within the row.
          onMoveLeft: onMoveToStage,
          onMoveUp: onMoveUp,
        ),
        const SizedBox(width: 12),
        _Action(
          target: VerticalPlayerControlTarget.save,
          iconAsset: uiState.isSaved
              ? AppAssets.bookmarkIcon
              : AppAssets.bookmarkOutlineIcon,
          label: 'Save',
          focusNodes: focusNodes,
          onPressed: onToggleSaved,
          onMoveUp: onMoveUp,
        ),
        if (uiState.settings.isAvailable) ...[
          const SizedBox(width: 12),
          _Action(
            target: VerticalPlayerControlTarget.settings,
            iconAsset: AppAssets.settingsIcon,
            label: 'Settings',
            focusNodes: focusNodes,
            onPressed: onOpenSettings,
            onMoveUp: onMoveUp,
          ),
        ],
      ],
    );
  }
}

final class _Action extends StatelessWidget {
  const _Action({
    required this.target,
    required this.iconAsset,
    required this.label,
    required this.focusNodes,
    required this.onPressed,
    required this.onMoveUp,
    this.onMoveLeft,
  });

  final VerticalPlayerControlTarget target;
  final String iconAsset;
  final String label;
  final Map<VerticalPlayerControlTarget, FocusNode> focusNodes;
  final VoidCallback onPressed;
  final VoidCallback onMoveUp;
  final VoidCallback? onMoveLeft;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKeyEvent,
      canRequestFocus: false,
      child: PlayerIconButton(
        iconAsset: iconAsset,
        semanticLabel: label,
        onPressed: onPressed,
        focusNode: focusNodes[target]!,
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      onMoveUp();
      return KeyEventResult.handled;
    }
    final moveLeft = onMoveLeft;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && moveLeft != null) {
      moveLeft();
      return KeyEventResult.handled;
    }
    // Right and Left between actions fall through to directional traversal, which walks the row.
    return KeyEventResult.ignored;
  }
}

final class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: StreamTvColors.live,
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        'LIVE',
        style: TextStyle(
          color: StreamTvColors.playerForeground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
