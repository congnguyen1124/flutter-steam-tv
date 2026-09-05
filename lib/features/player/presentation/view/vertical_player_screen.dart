import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section_stack.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_error_panel.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_parked_focus_target.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_section_host.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/vertical_player_ambient_background.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/vertical_player_interaction_panel.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/vertical_player_stage.dart';

/// Portrait playback: shorts, and the items in the vertical banner rows.
///
/// ## What it shares with the landscape player, and what it does not
///
/// Shared: [PlayerFocusOwner], [PlayerSectionStack], and every panel. Opening Settings → Quality
/// behaves identically on both screens because it is literally the same code — which is the point
/// of the section stack living in the model layer rather than inside either screen.
///
/// Different: **the base level**. The landscape player hides a transient control row behind a
/// passive surface, so it needs a `controller` phase and an auto-hide timer. Here the stage and the
/// interaction panel are both permanently on screen and focusable together, so there is nothing to
/// reveal and nothing to hide — [PlayerFocusOwner.controller] is simply never used, and there is no
/// timer.
///
/// ## Layout
///
/// Three regions across the panel: the ambient gradient, a 9:16 stage nudged toward the leading
/// edge, and the interaction panel in the width the stage leaves. The stage is sized from the panel
/// height rather than the video, so a portrait video of any resolution lands in the same box.
final class VerticalPlayerScreen extends StatefulWidget {
  /// The portrait player for [uiState].
  const VerticalPlayerScreen({
    required this.uiState,
    required this.videoSurface,
    required this.onTogglePlayPause,
    required this.onToggleLiked,
    required this.onToggleSaved,
    required this.onQualitySelected,
    required this.onAudioSelected,
    required this.onSubtitlesSelected,
    required this.onRetry,
    required this.onExit,
    super.key,
  });

  /// What to render.
  final PlayerUiState uiState;

  /// The native video surface, cropped to fill the stage.
  final Widget videoSurface;

  /// Select on the stage, or the play/pause key.
  final VoidCallback onTogglePlayPause;

  /// Toggle the like affordance.
  final VoidCallback onToggleLiked;

  /// Toggle the save affordance.
  final VoidCallback onToggleSaved;

  /// Select a video rendition.
  final ValueChanged<String> onQualitySelected;

  /// Select an audio rendition.
  final ValueChanged<String> onAudioSelected;

  /// Select a subtitle rendition.
  final ValueChanged<String> onSubtitlesSelected;

  /// Re-prepare and play after a failure.
  final VoidCallback onRetry;

  /// Leave the player.
  final VoidCallback onExit;

  @override
  State<VerticalPlayerScreen> createState() => _VerticalPlayerScreenState();
}

final class _VerticalPlayerScreenState extends State<VerticalPlayerScreen> {
  final Map<VerticalPlayerControlTarget, FocusNode> _controlNodes = {
    for (final target in VerticalPlayerControlTarget.values)
      target: FocusNode(debugLabel: 'vertical-player-${target.name}'),
  };
  final FocusNode _parkedNode = FocusNode(debugLabel: 'vertical-player-parked');

  PlayerSectionStack _sections = PlayerSectionStack.empty;

  PlayerFocusOwner get _focusOwner => resolvePlayerFocusOwner(
    hasError: widget.uiState.error != null,
    sections: _sections,
  );

  FocusNode get _stageNode => _controlNodes[VerticalPlayerControlTarget.stage]!;

  @override
  void initState() {
    super.initState();
    // The stage owns focus on entry: it is the play/pause control, and it is what Back returns to.
    WidgetsBinding.instance.addPostFrameCallback((_) => _claimStageFocus());
  }

  @override
  void didUpdateWidget(VerticalPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.uiState.error != null && _sections.hasSectionInPlay) {
      // An error outranks everything, and a panel animating over an error panel would be animating
      // content that has nothing behind it any more.
      setState(() => _sections = _sections.reset());
    }
    if (!widget.uiState.settings.isAvailable && _sections.hasSectionInPlay) {
      setState(() => _sections = _sections.reset());
      WidgetsBinding.instance.addPostFrameCallback((_) => _claimStageFocus());
    }
  }

  @override
  void dispose() {
    for (final node in _controlNodes.values) {
      node.dispose();
    }
    _parkedNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = widget.uiState;
    final error = uiState.error;
    final owner = _focusOwner;
    final isBaseFocusable = owner == PlayerFocusOwner.surface;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: StreamTvColors.playerBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const VerticalPlayerAmbientBackground(),
            if (error == null) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final stageHeight =
                      constraints.maxHeight -
                      VerticalPlayerStage.verticalPadding * 2;
                  final stageWidth =
                      stageHeight * VerticalPlayerStage.aspectRatio;
                  // Whatever the stage leaves, floored so a narrow panel still fits its controls.
                  final panelWidth = (constraints.maxWidth - stageWidth - 48)
                      .clamp(
                        VerticalPlayerInteractionPanel.minWidth,
                        constraints.maxWidth,
                      )
                      .toDouble();

                  return Row(
                    children: [
                      const SizedBox(width: 48),
                      SizedBox(
                        width: stageWidth,
                        height: stageHeight,
                        child: VerticalPlayerStage(
                          uiState: uiState,
                          videoSurface: widget.videoSurface,
                          focusNode: _stageNode,
                          canRequestFocus: isBaseFocusable,
                          onTogglePlayPause: widget.onTogglePlayPause,
                          onMoveToPanel: _focusFirstAction,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: panelWidth,
                          child: VerticalPlayerInteractionPanel(
                            uiState: uiState,
                            focusNodes: _controlNodes,
                            canRequestFocus: isBaseFocusable,
                            onOpenMetadata: () =>
                                _openSection(PlayerSection.metadata),
                            onOpenSettings: () =>
                                _openSection(PlayerSection.settings),
                            onToggleLiked: widget.onToggleLiked,
                            onToggleSaved: widget.onToggleSaved,
                            onMoveToStage: _claimStageFocus,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              PlayerParkedFocusTarget(focusNode: _parkedNode),
              PlayerSectionHost(
                sections: _sections,
                settings: uiState.settings,
                title: uiState.item.title,
                description: uiState.item.description,
                // Panels here slide in beside a stage the viewer can walk back to, so Left is the
                // natural way out as well as Back. On landscape it is not — see the spec.
                dismissOnLeft: true,
                // Transparent over the ambient gradient: a card here would draw a second surface on
                // top of one that is already deliberately empty. Landscape needs the card because
                // its panel sits over a moving picture.
                hasPanelBackground: false,
                onOpenSection: _openSection,
                onDismissSection: _dismissSection,
                onEnterFinished: _onSectionEnterFinished,
                onExitFinished: _onSectionExitFinished,
                onOptionSelected: _onSettingOptionSelected,
              ),
            ] else
              PlayerErrorPanel(
                error: error,
                onRetry: error.isRetryable ? widget.onRetry : null,
              ),
          ],
        ),
      ),
    );
  }

  void _claimStageFocus() {
    if (mounted && _focusOwner == PlayerFocusOwner.surface) {
      _stageNode.requestFocus();
    }
  }

  /// Right from the stage enters at the **first action**, not the title block.
  ///
  /// The action row is what a viewer reaches for; the title is one step Up from there.
  void _focusFirstAction() {
    if (_focusOwner != PlayerFocusOwner.surface) {
      return;
    }
    _controlNodes[VerticalPlayerControlTarget.like]?.requestFocus();
  }

  void _openSection(PlayerSection section) {
    final opened = _sections.open(section);
    if (opened == _sections) {
      return;
    }
    // Park before the panel appears: the interaction panel becomes unfocusable in the same frame,
    // and without somewhere to send focus first it falls back to the stage behind the panel.
    _parkedNode.requestFocus();
    setState(() => _sections = opened);
  }

  void _dismissSection() {
    final dismissed = _sections.dismissCurrent();
    if (dismissed == _sections) {
      return;
    }
    if (dismissed.stack.isNotEmpty) {
      _parkedNode.requestFocus();
    }
    setState(() => _sections = dismissed);
  }

  void _onSectionEnterFinished() {
    if (!_sections.isPanelEntering) {
      return;
    }
    setState(() => _sections = _sections.onEnterFinished());
  }

  void _onSectionExitFinished() {
    if (!_sections.isPanelExiting) {
      return;
    }
    setState(() => _sections = _sections.onExitFinished());
    // Closing a panel returns focus to the **stage**, not to the control that opened it. The
    // landscape player restores the opening control because its chrome is transient and gets
    // rebuilt; here the panel never went away, and the stage is where a viewer expects to land.
    if (_sections.isBaseLevel) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _claimStageFocus());
    }
  }

  void _onSettingOptionSelected(PlayerSettingKind kind, String optionId) {
    switch (kind) {
      case PlayerSettingKind.quality:
        widget.onQualitySelected(optionId);
      case PlayerSettingKind.audio:
        widget.onAudioSelected(optionId);
      case PlayerSettingKind.subtitles:
        widget.onSubtitlesSelected(optionId);
    }
    _dismissSection();
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) {
      return;
    }
    if (_sections.hasSectionInPlay) {
      _dismissSection();
      return;
    }
    widget.onExit();
  }
}
