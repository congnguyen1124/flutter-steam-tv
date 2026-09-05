/// A panel that stacks over a player.
///
/// Sections form a **tree**, not a flat list: opening Settings and then Quality leaves Settings
/// composed underneath, so returning from Quality restores the settings list exactly as it was —
/// its scroll position, and which row the viewer was on. [parent] is what makes that tree
/// navigable without each section having to know who opened it.
///
/// Ported from the OttClouds vertical player's `PlayerFocusableGroup`, minus the sections this app
/// has no data for yet (episodes, comments, replies, user playlists).
enum PlayerSection {
  /// Title, description and whatever else the catalogue knows about the item.
  metadata,

  /// The list of setting categories. Parent of the three below.
  settings,

  /// Video renditions.
  quality,

  /// Audio renditions.
  audio,

  /// Subtitle renditions.
  subtitles;

  /// The section revealed when this one is dismissed, or null when dismissing returns to the
  /// player.
  ///
  /// Declared here rather than passed in at open time so a section's place in the tree is a
  /// property of the section, not of the call site that happened to open it.
  PlayerSection? get parent => switch (this) {
    PlayerSection.metadata || PlayerSection.settings => null,
    PlayerSection.quality ||
    PlayerSection.audio ||
    PlayerSection.subtitles => PlayerSection.settings,
  };

  /// A short label for the panel's own header.
  String get title => switch (this) {
    PlayerSection.metadata => 'About',
    PlayerSection.settings => 'Settings',
    PlayerSection.quality => 'Quality',
    PlayerSection.audio => 'Audio',
    PlayerSection.subtitles => 'Subtitles',
  };
}
