import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section_stack.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_buffering_indicator.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_controller_chrome.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_error_panel.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_parked_focus_target.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_section_host.dart';

/// Landscape playback.
///
/// ## The two ideas worth knowing
///
/// **One focus owner.** [PlayerFocusOwner] is a single derived value, not a set of booleans each
/// effect interprets for itself. Every gate below reads it, so "who owns the D-pad right now" has
/// exactly one answer and the answer cannot contradict itself.
///
/// **Panels are a stack, not a flag.** [PlayerSectionStack] holds what is open and where each panel
/// is in its transition, so Settings → Quality keeps the settings list composed underneath and
/// returning to it restores the row the viewer was on. The portrait player uses the same stack and
/// the same panels; only the base level differs.
///
/// ## Layers, back to front
///
/// 1. Black, so nothing shows through before the first frame.
/// 2. [videoSurface] — the native player's own view.
/// 3. The input target: any D-pad press reveals the chrome. Focusable only while it owns focus, so
///    it releases focus on its own the moment the chrome appears.
/// 4. The buffering spinner.
/// 5. The controller chrome, fading in.
/// 6. The parked anchor, which holds focus while a panel animates.
/// 7. The panel stack.
/// 8. The error panel, which replaces everything above it.
///
/// ## Injected surface
///
/// [videoSurface] is a widget rather than a player, so this screen has no dependency on a native
/// player at all — which is what lets it be previewed and widget-tested. The route passes
/// `StreamPlayerView`; a preview passes a coloured box.
final class PlayerScreen extends StatefulWidget {
  /// The player screen for [uiState].
  const PlayerScreen({
    required this.uiState,
    required this.videoSurface,
    required this.onTogglePlayPause,
    required this.onSeekForward,
    required this.onSeekBack,
    required this.onToggleLiked,
    required this.onToggleSaved,
    required this.onQualitySelected,
    required this.onAudioSelected,
    required this.onSubtitlesSelected,
    required this.onRetry,
    required this.onExit,
    super.key,
  });

  /// How long the chrome stays up after the last interaction, while playing.
  static const Duration controllerAutoHide = Duration(seconds: 5);

  /// What to render.
  final PlayerUiState uiState;

  /// The native video surface.
  final Widget videoSurface;

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
  State<PlayerScreen> createState() => _PlayerScreenState();
}

final class _PlayerScreenState extends State<PlayerScreen> {
  /// Created once and owned here, not by the chrome.
  ///
  /// The chrome is built and destroyed every time it shows or hides; nodes that lived with it would
  /// be recreated each time, and "restore focus to the control that opened the panel" would have
  /// nothing to restore to.
  final Map<PlayerControlTarget, FocusNode> _controlNodes = {
    for (final target in PlayerControlTarget.values)
      target: FocusNode(debugLabel: 'player-${target.name}'),
  };
  final FocusNode _surfaceNode = FocusNode(debugLabel: 'player-surface');
  final FocusNode _parkedNode = FocusNode(debugLabel: 'player-parked');

  Timer? _autoHideTimer;
  bool _isControllerVisible = false;
  PlayerSectionStack _sections = PlayerSectionStack.empty;
  PlayerControlTarget _lastControlTarget = PlayerControlTarget.playPause;

  PlayerFocusOwner get _focusOwner => resolvePlayerFocusOwner(
    hasError: widget.uiState.error != null,
    sections: _sections,
    isControllerVisible: _isControllerVisible,
  );

  @override
  void initState() {
    super.initState();
    // Watch the nodes rather than have each button report upward. The buttons already own their
    // focus state for painting, and a second copy pushed up here could disagree with the first.
    //
    // `progress` is skipped on purpose: this value answers "which control row entry to come back
    // to", and the seek bar is what the viewer is coming back *from*.
    for (final entry in _controlNodes.entries) {
      if (entry.key == PlayerControlTarget.progress) {
        continue;
      }
      entry.value.addListener(() {
        if (entry.value.hasFocus) {
          _lastControlTarget = entry.key;
        }
      });
    }
    // The surface owns focus on entry, so the first D-pad press reveals the chrome rather than
    // being swallowed by whatever Flutter would otherwise have focused.
    WidgetsBinding.instance.addPostFrameCallback((_) => _claimSurfaceFocus());
  }

  @override
  void didUpdateWidget(PlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasError = widget.uiState.error != null;
    if (hasError && (_isControllerVisible || _sections.hasSectionInPlay)) {
      // An error outranks everything. Collapsing the chrome and clearing the stack here rather than
      // letting them linger is what stops focus sitting on a control whose player is dead. The
      // stack is reset without animation: a panel sliding out over an error panel would be
      // animating content that no longer has anything behind it.
      setState(() {
        _isControllerVisible = false;
        _sections = _sections.reset();
      });
      _autoHideTimer?.cancel();
    }
    // A setting category can disappear mid-session when a manifest reloads. A panel left open on it
    // would be empty and unfocusable, so drop back to the chrome.
    if (!widget.uiState.settings.isAvailable && _sections.hasSectionInPlay) {
      setState(() {
        _sections = _sections.reset();
        _isControllerVisible = true;
      });
    }
    // Playback resuming re-arms the timer; pausing stops it, so a paused controller stays up.
    if (oldWidget.uiState.isPlaying != widget.uiState.isPlaying) {
      _restartAutoHide();
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    for (final node in _controlNodes.values) {
      node.dispose();
    }
    _surfaceNode.dispose();
    _parkedNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = widget.uiState;
    final error = uiState.error;
    final owner = _focusOwner;

    return PopScope(
      // Never `true`. Back has four possible meanings here — pop a panel, hide the chrome, leave the
      // player, or leave a deep-linked player that has nothing to pop back to — and letting
      // Navigator handle some of them would split that decision across two places. One handler owns
      // all four; [PlayerScreen.onExit] owns the last two.
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: StreamTvColors.playerBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: StreamTvColors.playerBackground),
            widget.videoSurface,
            _InputTarget(
              focusNode: _surfaceNode,
              // Focusable only while it owns focus. That is what makes it release focus on its own
              // when the chrome appears, instead of competing with the chrome's entry request.
              canRequestFocus: owner == PlayerFocusOwner.surface,
              onReveal: _showController,
              onTogglePlayPause: () {
                widget.onTogglePlayPause();
                _showController();
              },
            ),
            if (error == null) ...[
              if (uiState.isBuffering)
                const Center(child: PlayerBufferingIndicator()),
              // Mounted only while it owns focus, because the chrome's entry focus request rides on
              // `autofocus` — which fires when a node is first attached, not when an opacity
              // changes. Keeping it mounted and merely invisible would mean no entry focus at all.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: owner == PlayerFocusOwner.controller
                    ? PlayerControllerChrome(
                        uiState: uiState,
                        focusNodes: _controlNodes,
                        entryTarget: _resolvedEntryTarget(),
                        onTogglePlayPause: widget.onTogglePlayPause,
                        onSeekForward: widget.onSeekForward,
                        onSeekBack: widget.onSeekBack,
                        onToggleLiked: widget.onToggleLiked,
                        onToggleSaved: widget.onToggleSaved,
                        onOpenMetadata: () =>
                            _openSection(PlayerSection.metadata),
                        onOpenSettings: () =>
                            _openSection(PlayerSection.settings),
                        onSeekBarMoveDown: _focusLastRowControl,
                        onInteraction: _onInteraction,
                      )
                    : const SizedBox.shrink(),
              ),
              // Always composed, so it is always a valid place to put focus. Removing it while a
              // panel animates is exactly when focus would fall back to the video surface.
              PlayerParkedFocusTarget(focusNode: _parkedNode),
              PlayerSectionHost(
                sections: _sections,
                settings: uiState.settings,
                title: uiState.item.title,
                description: uiState.item.description,
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

  /// The control to focus when the chrome appears.
  ///
  /// Falls back to play/pause when the remembered control is not on screen for this state — a live
  /// stream has no rewind button, and focusing a control that does not exist leaves the remote with
  /// nothing to aim at.
  PlayerControlTarget _resolvedEntryTarget() {
    final uiState = widget.uiState;
    final isAvailable = switch (_lastControlTarget) {
      PlayerControlTarget.progress ||
      PlayerControlTarget.rewind ||
      PlayerControlTarget.forward => uiState.isSeekable,
      PlayerControlTarget.settings => uiState.settings.isAvailable,
      PlayerControlTarget.description ||
      PlayerControlTarget.playPause ||
      PlayerControlTarget.like ||
      PlayerControlTarget.save => true,
    };
    return isAvailable ? _lastControlTarget : PlayerControlTarget.playPause;
  }

  /// Moves focus from the seek bar to the control the viewer last used.
  ///
  /// `spec/player.md` requires this, and requires it to be remembered state rather than a fixed
  /// target: pressing Down after scrubbing should return to the control the viewer was working
  /// with, not reset them to the start of the row.
  void _focusLastRowControl() {
    _controlNodes[_resolvedEntryTarget()]?.requestFocus();
  }

  void _claimSurfaceFocus() {
    if (mounted && _focusOwner == PlayerFocusOwner.surface) {
      _surfaceNode.requestFocus();
    }
  }

  void _showController() {
    _restartAutoHide();
    if (_isControllerVisible) {
      return;
    }
    setState(() => _isControllerVisible = true);
  }

  void _hideController() {
    _autoHideTimer?.cancel();
    setState(() => _isControllerVisible = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _claimSurfaceFocus());
  }

  /// Opens a panel, parking focus before the control that opened it leaves the tree.
  ///
  /// The park has to happen in the same frame as the open: the chrome unmounts immediately, and
  /// without somewhere to send focus first, Flutter's spatial search hands it to the video surface
  /// behind the panel.
  void _openSection(PlayerSection section) {
    final opened = _sections.open(section);
    if (opened == _sections) {
      return;
    }
    _autoHideTimer?.cancel();
    _parkedNode.requestFocus();
    setState(() {
      // Remembered so closing the panel returns focus to the control that opened it rather than to
      // the entry control, as `spec/player.md` requires.
      if (section == PlayerSection.settings) {
        _lastControlTarget = PlayerControlTarget.settings;
      } else if (section == PlayerSection.metadata) {
        _lastControlTarget = PlayerControlTarget.description;
      }
      _sections = opened;
      // Only the base level hides the chrome. A child panel opening over a parent must leave the
      // chrome flag alone, or dismissing back to the parent would also try to restore the chrome.
      if (section.parent == null) {
        _isControllerVisible = false;
      }
    });
  }

  void _dismissSection() {
    final dismissed = _sections.dismissCurrent();
    if (dismissed == _sections) {
      return;
    }
    // Parking only matters when a parent panel is revealed; returning to the base level has the
    // chrome to receive focus instead.
    if (dismissed.stack.isNotEmpty) {
      _parkedNode.requestFocus();
    }
    setState(() {
      _sections = dismissed;
      if (dismissed.stack.isEmpty) {
        _isControllerVisible = true;
      }
    });
    _restartAutoHide();
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
    // Choosing an option closes its panel and reveals the settings list underneath, so the viewer
    // can see the row they just changed rather than being dropped back at the video.
    _dismissSection();
  }

  void _onInteraction() => _restartAutoHide();

  /// Restarts the auto-hide countdown, or cancels it while paused or while a panel is open.
  ///
  /// A paused player keeps its chrome: the viewer stopped to look at something, and hiding the
  /// controls out from under them is the opposite of helpful.
  void _restartAutoHide() {
    _autoHideTimer?.cancel();
    if (!widget.uiState.isPlaying || _sections.hasSectionInPlay) {
      return;
    }
    _autoHideTimer = Timer(PlayerScreen.controllerAutoHide, () {
      if (mounted && _isControllerVisible && !_sections.hasSectionInPlay) {
        _hideController();
      }
    });
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) {
      // Unreachable while `canPop` is false, and guarded anyway: a pop that already happened must
      // not also run the in-screen back step, or leaving the player would close a panel behind it.
      return;
    }
    if (_sections.hasSectionInPlay) {
      _dismissSection();
      return;
    }
    if (_isControllerVisible) {
      _hideController();
      return;
    }
    widget.onExit();
  }
}

/// The full-screen key target behind the chrome.
///
/// Any D-pad press reveals the chrome and is consumed, so the press that summons the controls does
/// not also activate whichever control lands under focus — the Compose player needs an explicit
/// activation guard for the same reason.
final class _InputTarget extends StatelessWidget {
  const _InputTarget({
    required this.focusNode,
    required this.canRequestFocus,
    required this.onReveal,
    required this.onTogglePlayPause,
  });

  final FocusNode focusNode;
  final bool canRequestFocus;
  final VoidCallback onReveal;
  final VoidCallback onTogglePlayPause;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      descendantsAreFocusable: false,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        // A tap does what a Select press does, so the screen works on a touch device too.
        onTap: onReveal,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.mediaPlayPause:
        onTogglePlayPause();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        onReveal();
        return KeyEventResult.handled;

      case _:
        return KeyEventResult.ignored;
    }
  }
}
