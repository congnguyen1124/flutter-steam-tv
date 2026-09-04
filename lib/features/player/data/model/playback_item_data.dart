/// Transport shape for one playable item.
///
/// A plain class rather than a Freezed/JSON model: the only source today is the in-app catalogue
/// below, so there is no wire format to parse and no `fromJson` to generate. When a real API
/// appears, this is the type that grows `fromJson` — the domain model and the mapper above it do
/// not change.
final class PlaybackItemData {
  /// Describes one item as the data source holds it.
  const PlaybackItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.streamUrl,
    required this.isLive,
  });

  /// The catalogue id.
  final String id;

  /// Display title.
  final String title;

  /// One-line description.
  final String description;

  /// The manifest URL, unparsed.
  final String streamUrl;

  /// Whether the manifest is a live stream.
  final bool isLive;
}
