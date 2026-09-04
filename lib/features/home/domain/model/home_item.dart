enum HomeItemKind { video, series, channel, short }

final class HomeItem {
  const HomeItem({
    required this.id,
    this.videoUrl = '',
    this.trailerUrl = '',
    this.thumbnailUrl = '',
    this.vastUrl = '',
    required this.title,
    required this.description,
    this.ageRestriction,
    this.logoUrl = '',
    required this.kind,
    this.episodes = const [],
  });

  final String id;
  final String videoUrl;
  final String trailerUrl;
  final String thumbnailUrl;
  final String vastUrl;
  final String title;
  final String description;
  final String? ageRestriction;
  final String logoUrl;
  final HomeItemKind kind;
  final List<HomeItem> episodes;
}
