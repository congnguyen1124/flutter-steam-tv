import 'package:flutter/widgets.dart';

/// A one-pixel focusable anchor that holds focus for the length of a panel transition.
///
/// ## Why a screen needs somewhere to put focus
///
/// Opening a panel removes the focused control in the same frame. Flutter reacts by searching for
/// the nearest focusable thing, which on a player screen is the video surface — and the surface
/// then swallows the next key press, so the viewer's first press into the new panel does nothing.
///
/// Parking focus here first makes that search never happen. The anchor is always composed, so it is
/// always a valid target, and it consumes every key it receives so a press that lands during the
/// animation cannot leak to whatever is behind it.
///
/// Ported from OttClouds' `PendingFocusTarget`.
final class PlayerParkedFocusTarget extends StatelessWidget {
  /// Parks focus on [focusNode] while a transition runs.
  const PlayerParkedFocusTarget({required this.focusNode, super.key});

  /// Owned by the screen, which is the only thing that decides when focus parks.
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Focus(
        focusNode: focusNode,
        // Every key is swallowed: during a transition there is nothing sensible to do with one, and
        // letting it through reaches the surface behind the panel that is animating in.
        onKeyEvent: (node, event) => KeyEventResult.handled,
        child: const SizedBox.square(dimension: 1),
      ),
    );
  }
}
