import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section_stack.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_animated_section.dart';
import 'package:flutter_steam_tv/features/player/presentation/widget/player_section_panel.dart';

/// Renders every open panel, one on top of the other, and drives their transitions.
///
/// ## The two rules that make the stack work
///
/// 1. **Every layer stays composed.** Settings does not leave the tree when Quality opens on top of
///    it, so returning from Quality restores its scroll position and the row the viewer was on —
///    for free, because nothing was ever rebuilt. Only the top layer is painted.
/// 2. **Only the settled top layer is focusable.** A panel sliding in cannot take focus yet, and a
///    panel sliding out has already given it up. `ExcludeFocus` on every other layer is what stops
///    a D-pad press from reaching a panel the viewer cannot see.
///
/// The whole widget is driven by [sections] and reports back through [onEnterFinished] and
/// [onExitFinished]; it owns no state of its own, so what is on screen and what the stack says can
/// never disagree.
///
/// Shared by both players. Ported from OttClouds' `VerticalPlayerSideSection`.
final class PlayerSectionHost extends StatelessWidget {
  /// Renders the panels described by [sections].
  const PlayerSectionHost({
    required this.sections,
    required this.settings,
    required this.title,
    required this.description,
    required this.onOpenSection,
    required this.onDismissSection,
    required this.onEnterFinished,
    required this.onExitFinished,
    required this.onOptionSelected,
    this.dismissOnLeft = false,
    this.hasPanelBackground = true,
    super.key,
  });

  /// Panel width. Matches the Compose reference's side section.
  static const double panelWidth = 360;

  /// What is open and where each panel is in its transition.
  final PlayerSectionStack sections;

  /// What the settings panels can offer.
  final PlayerSettingsUiState settings;

  /// Item title, for the metadata panel.
  final String title;

  /// Item description, for the metadata panel.
  final String description;

  /// Push a child panel — a setting category from the settings list.
  final ValueChanged<PlayerSection> onOpenSection;

  /// Pop the top panel.
  final VoidCallback onDismissSection;

  /// The top panel finished sliding in.
  final VoidCallback onEnterFinished;

  /// The popped panel finished sliding out.
  final VoidCallback onExitFinished;

  /// A rendition was chosen in one of the option panels.
  final void Function(PlayerSettingKind kind, String optionId) onOptionSelected;

  /// Whether Left dismisses a panel as well as Back.
  ///
  /// True on the portrait player, where panels slide in from the trailing edge next to a stage the
  /// viewer can walk back to; false on landscape, where Left inside a panel is a list interaction.
  /// The difference is required by `spec/vertical-player.md`.
  final bool dismissOnLeft;

  /// Whether the panel draws a rounded translucent card behind its content.
  ///
  /// True on landscape, where the panel sits over the video and needs to be read against a moving
  /// picture. False on portrait, where it sits over the ambient gradient — a card there would draw a
  /// second surface on top of one that is already deliberately empty. Required by
  /// `spec/vertical-player.md`, "Visual differences from landscape".
  final bool hasPanelBackground;

  @override
  Widget build(BuildContext context) {
    if (sections.sectionLayers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: panelWidth,
        child: Stack(
          children: [
            for (final section in sections.sectionLayers)
              _Layer(
                // Keyed by section, so switching panels builds a fresh animation controller and
                // the new panel starts off-screen instead of wherever the previous one stopped.
                key: ValueKey<PlayerSection>(section),
                isTop: section == sections.panelSection,
                sections: sections,
                onEnterFinished: onEnterFinished,
                onExitFinished: onExitFinished,
                child: _content(section),
              ),
          ],
        ),
      ),
    );
  }

  Widget _content(PlayerSection section) {
    final isSettled =
        sections.isPanelSettled && section == sections.panelSection;
    return PlayerSectionPanel(
      section: section,
      isFocusEnabled: isSettled,
      dismissOnLeft: dismissOnLeft,
      hasPanelBackground: hasPanelBackground,
      onDismiss: onDismissSection,
      title: title,
      description: description,
      settings: settings,
      onOpenSection: onOpenSection,
      onOptionSelected: onOptionSelected,
    );
  }
}

/// One layer of the stack: painted only when it is on top, focusable only when it is settled.
///
/// Owns the focus scope for its panel and claims focus the moment the layer settles. That claim is
/// the other half of parking: the screen parks focus when a panel opens, and **something has to
/// unpark it** — otherwise focus sits on the off-screen anchor, which swallows every key, and the
/// viewer cannot even press Back.
///
/// It cannot be done with `autofocus`, which fires when a node first attaches — and a panel
/// attaches while it is still sliding in, before it is allowed to hold focus.
final class _Layer extends StatefulWidget {
  const _Layer({
    required this.isTop,
    required this.sections,
    required this.onEnterFinished,
    required this.onExitFinished,
    required this.child,
    super.key,
  });

  final bool isTop;
  final PlayerSectionStack sections;
  final VoidCallback onEnterFinished;
  final VoidCallback onExitFinished;
  final Widget child;

  @override
  State<_Layer> createState() => _LayerState();
}

final class _LayerState extends State<_Layer> {
  final FocusScopeNode _scope = FocusScopeNode(debugLabel: 'player-section');

  bool get _isSettled => widget.isTop && widget.sections.isPanelSettled;

  @override
  void didUpdateWidget(_Layer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSettled = oldWidget.isTop && oldWidget.sections.isPanelSettled;
    if (!wasSettled && _isSettled) {
      // Post-frame, because `ExcludeFocus` below only stops excluding in the build this update
      // triggers — requesting focus before that lands would be refused.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isSettled) {
          _scope.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTop = widget.isTop;
    final sections = widget.sections;
    final child = widget.child;
    final onEnterFinished = widget.onEnterFinished;
    final onExitFinished = widget.onExitFinished;
    final isSettled = _isSettled;
    return Positioned.fill(
      child: FocusScope(
        node: _scope,
        child: ExcludeFocus(
          // Not just the layers underneath: a panel mid-transition is excluded too. Focus belongs to
          // the parked anchor until the animation ends.
          excluding: !isSettled,
          child: IgnorePointer(
            ignoring: !isTop,
            child: Opacity(
              // Kept in the tree at zero opacity rather than removed, so its scroll position and
              // focused row survive a child panel opening over it.
              opacity: isTop ? 1 : 0,
              child: PlayerAnimatedSection(
                isEntering: isTop && sections.isPanelEntering,
                isExiting: isTop && sections.isPanelExiting,
                onEnterFinished: onEnterFinished,
                onExitFinished: onExitFinished,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Left-to-dismiss, on the players that want it.
///
/// Back is deliberately **not** handled here. It arrives as a system pop, which `PopScope` on the
/// screen already owns, and handling the `goBack` key as well would let one press dismiss two
/// panels on a remote that sends both.
///
/// Lives here rather than in each panel so a new panel cannot forget to be dismissable.
final class PlayerSectionKeyHandler extends StatelessWidget {
  /// Wraps [child] with the dismissal keys.
  const PlayerSectionKeyHandler({
    required this.onDismiss,
    required this.dismissOnLeft,
    required this.child,
    super.key,
  });

  /// Pop this panel.
  final VoidCallback onDismiss;

  /// Whether Left dismisses as well as Back.
  final bool dismissOnLeft;

  /// The panel.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(onKeyEvent: _onKeyEvent, canRequestFocus: false, child: child);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (dismissOnLeft && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      onDismiss();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

/// The shared visual shell of a panel: rounded, opaque enough to read over video, with a header.
final class PlayerSectionSurface extends StatelessWidget {
  /// Wraps [child] in the panel shell, headed by [title].
  const PlayerSectionSurface({
    required this.title,
    required this.hasBackground,
    required this.child,
    super.key,
  });

  /// Shown at the top of the panel.
  final String title;

  /// Whether to draw the rounded translucent card.
  final bool hasBackground;

  /// The panel body.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hasBackground
              ? StreamTvColors.playerPanel
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                title,
                style: const TextStyle(
                  color: StreamTvColors.playerForeground,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
