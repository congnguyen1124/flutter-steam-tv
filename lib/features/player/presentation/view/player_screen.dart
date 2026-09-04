import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_buffering_indicator.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_controller_chrome.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_error_panel.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_settings_panel.dart';

/// Landscape playback.
///
/// ## The one idea worth knowing
///
/// Focus ownership runs through a single value — [PlayerFocusOwner] — rather than a set of booleans
/// each effect interprets for itself. Every gate below reads that one value, so "who owns the D-pad
/// right now" has exactly one answer and the answer cannot contradict itself. That is ported
/// directly from the Compose player, where the flags-based version raced: a panel opening while the
/// controller was still marked visible left two subtrees each believing focus was theirs.
///
/// ## Layers, back to front
///
/// 1. Black, so nothing shows through before the first frame.
/// 2. [videoSurface] — the native player's own view.
/// 3. The input target: any D-pad press reveals the chrome. Focusable only while it owns focus, so
///    it releases focus on its own the moment the chrome appears.
/// 4. The buffering spinner.
/// 5. The controller chrome, sliding up.
/// 6. The settings panel.
/// 7. The error panel, which replaces everything above it.
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

  Timer? _autoHideTimer;
  bool _isControllerVisible = false;
  bool _isSettingsOpen = false;
  PlayerControlTarget _lastControlTarget = PlayerControlTarget.playPause;

  PlayerFocusOwner get _focusOwner => resolvePlayerFocusOwner(
    hasError: widget.uiState.error != null,
    isSettingsOpen: _isSettingsOpen,
    isControllerVisible: _isControllerVisible,
  );

  @override
  void initState() {
    super.initState();
    // The surface owns focus on entry, so the first D-pad press reveals the chrome rather than
    // being swallowed by whatever Flutter would otherwise have focused.
    WidgetsBinding.instance.addPostFrameCallback((_) => _claimSurfaceFocus());
  }

  @override
  void didUpdateWidget(PlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasError = widget.uiState.error != null;
    if (hasError && (_isControllerVisible || _isSettingsOpen)) {
      // An error outranks everything. Collapsing the chrome here rather than letting it linger is
      // what stops focus sitting on a control whose player is dead.
      setState(() {
        _isControllerVisible = false;
        _isSettingsOpen = false;
      });
      _autoHideTimer?.cancel();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = widget.uiState;
    final error = uiState.error;
    final owner = _focusOwner;

    return PopScope(
      // Back is a step within the screen while any chrome is up, and only then a pop.
      canPop: owner == PlayerFocusOwner.surface || owner == PlayerFocusOwner.error,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: StreamTvColors.playerBackground,
        body: Stack(
          fit: .expand,
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
              if (uiState.isBuffering) const Center(child: PlayerBufferingIndicator()),
              // Mounted only while it owns focus, because the chrome's entry focus request rides
              // on `autofocus` — which fires when a node is first attached, not when an opacity
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
                        onOpenSettings: _openSettings,
                        onInteraction: _onInteraction,
                      )
                    : const SizedBox.shrink(),
              ),
              if (owner == PlayerFocusOwner.settings)
                PlayerSettingsPanel(
                  settings: uiState.settings,
                  onOptionSelected: _onSettingOptionSelected,
                  onDismiss: _closeSettings,
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
      PlayerControlTarget.playPause ||
      PlayerControlTarget.like ||
      PlayerControlTarget.save => true,
    };
    return isAvailable ? _lastControlTarget : PlayerControlTarget.playPause;
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

  void _openSettings() {
    _autoHideTimer?.cancel();
    _rememberFocusedControl();
    setState(() {
      _lastControlTarget = PlayerControlTarget.settings;
      _isSettingsOpen = true;
      _isControllerVisible = false;
    });
  }

  void _closeSettings() {
    setState(() {
      _isSettingsOpen = false;
      _isControllerVisible = true;
    });
    _restartAutoHide();
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
  }

  void _onInteraction() {
    _rememberFocusedControl();
    _restartAutoHide();
  }

  /// Records which control has focus, so the chrome can come back to it.
  ///
  /// Read from the nodes rather than reported upward by each button: the buttons already own their
  /// focus state for painting, and having them also push it here would be a second copy that can
  /// disagree with the first.
  void _rememberFocusedControl() {
    for (final entry in _controlNodes.entries) {
      if (entry.value.hasFocus) {
        _lastControlTarget = entry.key;
        return;
      }
    }
  }

  /// Restarts the auto-hide countdown, or cancels it while paused.
  ///
  /// A paused player keeps its chrome: the viewer stopped to look at something, and hiding the
  /// controls out from under them is the opposite of helpful.
  void _restartAutoHide() {
    _autoHideTimer?.cancel();
    if (!widget.uiState.isPlaying) {
      return;
    }
    _autoHideTimer = Timer(PlayerScreen.controllerAutoHide, () {
      if (mounted && _isControllerVisible && !_isSettingsOpen) {
        _hideController();
      }
    });
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) {
      return;
    }
    if (_isSettingsOpen) {
      _closeSettings();
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
        behavior: .opaque,
        child: const SizedBox.expand(),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return .ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.mediaPlayPause:
        onTogglePlayPause();
        return .handled;

      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        onReveal();
        return .handled;

      case _:
        return .ignored;
    }
  }
}
