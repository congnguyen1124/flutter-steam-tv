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
/// ## Why it is skipped by traversal
///
/// Always composed and always focusable is one node too many for the D-pad: the anchor sits at the
/// leading edge of the screen, so a Left press from the leading-most control finds it by directional
/// traversal and parks focus on it with no transition running. The screen does not model that — its
/// owner is derived from the section stack, which is empty — so it believes the chrome owns focus
/// while the anchor is silently eating every key. The chrome then auto-hides, comes back on the next
/// press, and comes back **unfocused**: its entry request rides on `autofocus`, which does nothing
/// while a sibling in the same scope already holds focus. The result is a visible controller that
/// cannot be operated, exactly the failure `spec/player.md` warns about.
///
/// [FocusNode.skipTraversal] is the precise remedy: it removes the anchor from every traversal
/// policy while leaving `requestFocus` working, so focus arrives here only when the screen puts it
/// here.
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
        // Reachable by `requestFocus` only, never by a D-pad move. See the class doc.
        skipTraversal: true,
        // Every key is swallowed: during a transition there is nothing sensible to do with one, and
        // letting it through reaches the surface behind the panel that is animating in.
        onKeyEvent: (node, event) => KeyEventResult.handled,
        child: const SizedBox.square(dimension: 1),
      ),
    );
  }
}
