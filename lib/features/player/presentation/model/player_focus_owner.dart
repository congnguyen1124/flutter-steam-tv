/// Which subtree owns D-pad focus. Exactly one at a time.
///
/// ## Why a value and not a set of booleans
///
/// The obvious way to write this screen is a handful of flags — controller visible, settings open,
/// error showing — each read by whichever effect happens to care. Those can disagree: settings
/// opening while the controller is still marked visible leaves two subtrees each believing focus is
/// theirs, and which one wins depends on which effect ran last. That is a race, and on a TV it
/// shows up as a remote that stops responding.
///
/// Naming the owner makes the contradiction unrepresentable, and gives every gate on the screen one
/// value to read.
///
/// Mirrors the Compose app's `PlayerFocusableGroup`.
enum PlayerFocusOwner {
  /// The bare video surface. Any D-pad press reveals the controller.
  surface,

  /// The controller chrome: seek bar and control row.
  controller,

  /// The settings panel.
  settings,

  /// The error panel, so its retry button can be reached.
  error,
}

/// Resolves the single focus owner.
///
/// Order is the precedence: an error outranks everything, an open panel outranks the controller
/// underneath it, and the controller outranks the bare surface.
///
/// Pure on purpose — the ordering is the part worth testing, and it needs no widget tree to check.
PlayerFocusOwner resolvePlayerFocusOwner({
  required bool hasError,
  required bool isSettingsOpen,
  required bool isControllerVisible,
}) {
  if (hasError) {
    return PlayerFocusOwner.error;
  }
  if (isSettingsOpen) {
    return PlayerFocusOwner.settings;
  }
  if (isControllerVisible) {
    return PlayerFocusOwner.controller;
  }
  return PlayerFocusOwner.surface;
}

/// Every control the controller row can hold focus on, in visual order.
///
/// A closed set so the screen can name the control to restore when a panel closes — "reopen the
/// controller on Settings" has to survive the controller subtree being rebuilt, which a bare
/// `FocusNode` reference does not.
enum PlayerControlTarget {
  /// The seek bar. Spans the full width above the control row.
  progress,

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
