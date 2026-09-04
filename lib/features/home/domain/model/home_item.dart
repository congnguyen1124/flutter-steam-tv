enum HomeItemKind { video, series, channel, short }

final class HomeItem {
  const HomeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
  });

  final String id;
  final String title;
  final String description;
  final HomeItemKind kind;
}
