import 'package:flutter/foundation.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section.dart';

/// Which panels are stacked over the player, and where each one is in its transition.
///
/// ## Why a stack, and why the transition phases are part of it
///
/// A player screen is a small stack of panels over the video. The obvious model — one nullable
/// "open section" — cannot express Settings → Quality, so returning from Quality would rebuild
/// Settings from scratch and lose the row the viewer was on.
///
/// The transition phases are here for a subtler reason, and it is the whole reason this type
/// exists rather than a plain `List`. A panel that is *sliding in* must not hold focus yet, and a
/// panel that is *sliding out* must stay composed until its animation ends. Two facts, and every
/// visibility and focus decision on the screen depends on which of them is true. Left as separate
/// booleans next to the list they drift apart, and the failure is a remote that stops responding
/// because two subtrees each believe focus is theirs.
///
/// So: immutable value, pure transitions, one place to ask "what is on screen and can it take
/// focus". Testable with no widget tree — see `player_section_stack_test.dart`.
///
/// Ported from the OttClouds vertical player's `VerticalPlayerFocusState`, which is a mutable
/// `@Stable` class; an immutable value suits Flutter better and makes the transitions trivially
/// assertable.
@immutable
final class PlayerSectionStack {
  /// Builds a stack directly. Prefer [empty] and the transitions.
  const PlayerSectionStack({
    this.stack = const <PlayerSection>[],
    this.exitingSection,
    this.isEntering = false,
  });

  /// The base level: no panel open, the player owns the screen.
  static const PlayerSectionStack empty = PlayerSectionStack();

  /// Open sections, parent first. The last is the one on top.
  final List<PlayerSection> stack;

  /// The section sliding out after a dismiss, or null when nothing is exiting.
  ///
  /// Kept out of [stack] on purpose: it is no longer navigable — Back must act on what is
  /// underneath it — but it must still be composed until its animation ends.
  final PlayerSection? exitingSection;

  /// Whether the top section is still sliding in.
  final bool isEntering;

  /// The section composed on top right now: the one exiting, otherwise the top of the stack.
  PlayerSection? get panelSection =>
      exitingSection ?? (stack.isEmpty ? null : stack.last);

  /// Every section that must stay composed, parent first.
  ///
  /// A dismissed section is still in here while it animates out, which is what lets it slide
  /// rather than vanish.
  List<PlayerSection> get sectionLayers => exitingSection == null
      ? stack
      : <PlayerSection>[...stack, exitingSection!];

  /// True while the top panel is sliding in.
  bool get isPanelEntering => isEntering && exitingSection == null;

  /// True while a panel is sliding out.
  bool get isPanelExiting => exitingSection != null;

  /// True while a panel is on screen and idle — the only state in which it may hold focus.
  bool get isPanelSettled =>
      panelSection != null && !isPanelEntering && !isPanelExiting;

  /// True at the base level with no transition running.
  bool get isBaseLevel => stack.isEmpty && exitingSection == null;

  /// True whenever a section is open or still animating — what Back should be gated on.
  bool get hasSectionInPlay => stack.isNotEmpty || exitingSection != null;

  /// Pushes [section] and starts its enter animation.
  ///
  /// Ignored while another section is entering or exiting, so two fast presses cannot interleave
  /// two transitions and leave the stack describing a screen that is not on it.
  PlayerSectionStack open(PlayerSection section) {
    if (isEntering || exitingSection != null) {
      return this;
    }
    return PlayerSectionStack(
      stack: <PlayerSection>[...stack, section],
      isEntering: true,
    );
  }

  /// Marks the top section settled once its enter animation finished.
  PlayerSectionStack onEnterFinished() {
    if (!isEntering) {
      return this;
    }
    return PlayerSectionStack(stack: stack, exitingSection: exitingSection);
  }

  /// Pops the top section and starts its exit animation.
  ///
  /// The popped section keeps composing until [onExitFinished], so it can slide out.
  PlayerSectionStack dismissCurrent() {
    if (exitingSection != null || stack.isEmpty) {
      return this;
    }
    return PlayerSectionStack(
      stack: stack.sublist(0, stack.length - 1),
      exitingSection: stack.last,
    );
  }

  /// Drops the popped section from the composition once its exit animation finished.
  PlayerSectionStack onExitFinished() {
    if (exitingSection == null) {
      return this;
    }
    return PlayerSectionStack(stack: stack, isEntering: isEntering);
  }

  /// Clears everything with no animation.
  ///
  /// For the cases where the screen underneath changed out from under the panels — a failure, or
  /// the vertical player moving to another video — and animating a panel belonging to content that
  /// is gone would be wrong.
  PlayerSectionStack reset() => empty;

  @override
  bool operator ==(Object other) =>
      other is PlayerSectionStack &&
      listEquals(other.stack, stack) &&
      other.exitingSection == exitingSection &&
      other.isEntering == isEntering;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(stack), exitingSection, isEntering);

  @override
  String toString() =>
      'PlayerSectionStack(${stack.map((s) => s.name).join(' > ')}'
      '${exitingSection == null ? '' : ', exiting: ${exitingSection!.name}'}'
      '${isEntering ? ', entering' : ''})';
}
