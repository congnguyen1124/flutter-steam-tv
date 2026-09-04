import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';

enum HomeSectionViewType {
  banner,
  verticalBanner,
  videos,
  videosPopular,
  listSeries,
  channels,
  shorts,
  shortPopular;

  bool accepts(HomeItemKind kind) {
    return switch (this) {
      .banner || .videos || .videosPopular => kind == .video,
      .verticalBanner || .shorts || .shortPopular => kind == .short,
      .listSeries => kind == .series,
      .channels => kind == .channel,
    };
  }

  bool get isBanner => this == .banner || this == .verticalBanner;
  bool get isRanked => this == .videosPopular || this == .shortPopular;
  bool get usesPortraitCards =>
      this == .verticalBanner || this == .shorts || this == .shortPopular;
}

final class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.viewType,
    required this.items,
  });

  final String id;
  final String title;
  final HomeSectionViewType viewType;
  final List<HomeItem> items;
}
