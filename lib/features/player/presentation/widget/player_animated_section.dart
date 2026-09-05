import 'dart:async';

import 'package:flutter/widgets.dart';

/// Slides one panel in from, or out to, the trailing edge, and reports when it settles.
///
/// ## Why the callbacks matter
///
/// The section stack cannot advance its own phases — it does not know how long an animation takes.
/// This widget is what closes that loop: [onEnterFinished] promotes the panel from *entering* to
/// *settled*, which is what finally lets it take focus, and [onExitFinished] drops the popped panel
/// from the composition. Miss either callback and the screen is stuck with focus parked on an
/// off-screen anchor.
///
/// The animation state lives for the whole composition, so the caller must give each panel its own
/// key — otherwise switching sections reuses the controller and the new panel starts from wherever
/// the old one stopped instead of off-screen.
///
/// Ported from OttClouds' `AnimatedSideSection`.
final class PlayerAnimatedSection extends StatefulWidget {
  /// Animates [child] according to [isEntering] and [isExiting].
  const PlayerAnimatedSection({
    required this.isEntering,
    required this.isExiting,
    required this.onEnterFinished,
    required this.onExitFinished,
    required this.child,
    super.key,
  });

  /// How long a panel takes to slide in or out.
  static const Duration duration = Duration(milliseconds: 300);

  /// Whether this panel is sliding in.
  final bool isEntering;

  /// Whether this panel is sliding out.
  final bool isExiting;

  /// Called once the enter slide settles.
  final VoidCallback onEnterFinished;

  /// Called once the exit slide completes.
  final VoidCallback onExitFinished;

  /// The panel.
  final Widget child;

  @override
  State<PlayerAnimatedSection> createState() => _PlayerAnimatedSectionState();
}

final class _PlayerAnimatedSectionState extends State<PlayerAnimatedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PlayerAnimatedSection.duration,
    // A panel that is already settled when it first composes starts on screen; one that is
    // entering starts fully off it.
    value: widget.isEntering ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    // The transition outlives this call; its completion is reported through the callbacks, so
    // there is nothing here to await.
    unawaited(_runTransition());
  }

  @override
  void didUpdateWidget(PlayerAnimatedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEntering != widget.isEntering ||
        oldWidget.isExiting != widget.isExiting) {
      unawaited(_runTransition());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FractionalTranslation(
        translation: Offset(_controller.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }

  Future<void> _runTransition() async {
    if (widget.isEntering) {
      _controller.value = 1;
      await _controller.animateTo(0);
      // `mounted` because a panel can be dismissed mid-slide; reporting "entered" for a widget
      // that is already leaving would settle a section the stack has moved past.
      if (mounted) {
        widget.onEnterFinished();
      }
      return;
    }
    if (widget.isExiting) {
      await _controller.animateTo(1);
      if (mounted) {
        widget.onExitFinished();
      }
      return;
    }
    _controller.value = 0;
  }
}
