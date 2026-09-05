import 'package:flutter_steam_tv/features/player/presentation/model/player_section_stack.dart';

/// Which subtree owns the D-pad. Exactly one at a time, on both players.
///
/// ## Why a value and not a set of booleans
///
/// The obvious way to write a player screen is a handful of flags — chrome visible, panel open,
/// error showing — each read by whichever effect happens to care. Those can disagree: a panel
/// opening while the chrome is still marked visible leaves two subtrees each believing focus is
/// theirs, and which one wins depends on which effect ran last. On a TV that shows up as a remote
/// that stops responding.
///
/// Naming the owner makes the contradiction unrepresentable, and gives every gate on the screen one
/// value to read.
///
/// Matches `steam_tv/spec/player.md` exactly, including [parked], and is shared by the landscape
/// and portrait players so "who owns the D-pad" means the same thing on both.
enum PlayerFocusOwner {
  /// The video surface. Landscape: the full-screen input target behind the chrome. Portrait: the
  /// stage, which is a real control — Select on it toggles playback.
  surface,

  /// The transient landscape chrome: seek bar and control row.
  ///
  /// Never used by the portrait player, which has no transient chrome — its interaction panel is
  /// part of the base level and is focusable alongside the stage.
  controller,

  /// A settled panel owns focus.
  section,

  /// Focus is parked on an off-screen anchor for the length of a transition.
  ///
  /// Without it, the focused control disappears mid-animation and Flutter falls back to whatever is
  /// spatially nearest — which is the video surface, which then swallows the next key press.
  parked,

  /// The error panel, so its retry control can be reached.
  error,
}

/// Resolves the single focus owner.
///
/// Precedence, highest first: [PlayerFocusOwner.error], [PlayerFocusOwner.parked],
/// [PlayerFocusOwner.section], [PlayerFocusOwner.controller], [PlayerFocusOwner.surface]. An error
/// outranks everything; a transition outranks the section it animates; a live section outranks the
/// chrome beneath it.
///
/// The one asymmetry worth reading twice: a panel exiting **to the base level** hands focus straight
/// back to the chrome or surface rather than parking, because there is a settled destination
/// already on screen to receive it. A panel exiting **onto a parent panel** must park, because the
/// parent cannot take focus until the animation frees it.
///
/// Pure — the ordering is the part worth testing, and it needs no widget tree to check.
PlayerFocusOwner resolvePlayerFocusOwner({
  required bool hasError,
  required PlayerSectionStack sections,
  bool isControllerVisible = false,
}) {
  if (hasError) {
    return PlayerFocusOwner.error;
  }
  if (sections.isPanelEntering) {
    return PlayerFocusOwner.parked;
  }
  if (sections.isPanelExiting) {
    return sections.stack.isNotEmpty
        ? PlayerFocusOwner.parked
        : _baseOwner(isControllerVisible: isControllerVisible);
  }
  if (sections.stack.isNotEmpty) {
    return PlayerFocusOwner.section;
  }
  return _baseOwner(isControllerVisible: isControllerVisible);
}

PlayerFocusOwner _baseOwner({required bool isControllerVisible}) =>
    isControllerVisible
    ? PlayerFocusOwner.controller
    : PlayerFocusOwner.surface;

/// Every control the landscape controller row can hold focus on, in visual order.
///
/// A closed set so the screen can name the control to restore when a panel closes — "reopen the
/// controller on Settings" has to survive the controller subtree being rebuilt, which a bare
/// `FocusNode` reference does not.
enum PlayerControlTarget {
  /// The seek bar. Spans the full width above the control row.
  progress,

  /// Leading pill. Opens the metadata section.
  description,

  /// Seek back by the configured increment.
  rewind,

  /// The transport primary.
  playPause,

  /// Seek forward by the configured increment.
  forward,

  /// Like this item.
  like,

  /// Save this item.
  save,

  /// Open the settings panel.
  settings,
}

/// Every control the portrait interaction panel can hold focus on, in visual order.
///
/// Separate from [PlayerControlTarget] because the two rows genuinely differ: the portrait panel
/// has no transport cluster and no seek bar, and its title block is the metadata entry point that
/// the landscape player reaches through a pill. Sharing one enum would mean every `switch` on
/// either screen carrying arms that can never occur there.
enum VerticalPlayerControlTarget {
  /// The portrait video stage. Focusable, and Select toggles playback.
  stage,

  /// Title block. Opens the metadata section.
  title,

  /// Like this item.
  like,

  /// Open the comments section. Present only when the catalogue can serve comments.
  comment,

  /// Save this item.
  save,

  /// Open the settings panel.
  settings,
}
