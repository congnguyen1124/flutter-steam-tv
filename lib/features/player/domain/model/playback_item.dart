/// What the player needs to know about one item.
///
/// Deliberately thin. The player screen renders a title, decides whether a seek bar makes sense,
/// and plays a URL — nothing else. Cast lists, genres and comments belong to a detail feature, and
/// putting them here would make every playback path depend on content the player never draws.
final class PlaybackItem {
  /// Describes one playable item.
  const PlaybackItem({
    required this.id,
    required this.title,
    required this.description,
    required this.streamUrl,
    required this.isLive,
  });

  /// The catalogue id this item was resolved from.
  final String id;

  /// Shown in the controller's title block.
  final String title;

  /// One line under the title.
  final String description;

  /// The manifest to play.
  final Uri streamUrl;

  /// Whether this is a live stream.
  ///
  /// Drives two decisions the player cannot infer quickly enough on its own: a live stream gets no
  /// seek bar, and resuming from pause jumps to the live edge rather than to where the viewer
  /// stopped — which otherwise silently leaves them behind the broadcast with no way back.
  final bool isLive;
}
