import 'package:flutter_steam_tv/features/home/data/model/home_item_dto.dart';
import 'package:flutter_steam_tv/features/home/data/model/home_section_dto.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';

extension HomeSectionDtoMapper on HomeSectionDto {
  HomeSection toDomain() {
    final domainViewType = HomeSectionViewType.values.firstWhere(
      (value) => value.name == viewType,
      orElse: () => throw FormatException(
        'Unsupported Home section view type: $viewType',
      ),
    );
    final domainItems = List<HomeItem>.unmodifiable(
      items.map((item) => item.toDomain()),
    );
    if (domainItems.isEmpty) {
      throw StateError('Home section $id must not be empty');
    }
    if (!domainItems.every((item) => domainViewType.accepts(item.kind))) {
      throw StateError(
        'Home section $id contains an item incompatible with $viewType',
      );
    }

    return HomeSection(
      id: id,
      title: title,
      viewType: domainViewType,
      items: domainItems,
    );
  }
}

extension on HomeItemDto {
  HomeItem toDomain() {
    return HomeItem(
      id: id,
      videoUrl: videoUrl,
      trailerUrl: trailerUrl,
      thumbnailUrl: thumbnailUrl,
      vastUrl: vastUrl,
      title: title,
      description: description,
      ageRestriction: ageRestriction,
      logoUrl: logoUrl,
      kind: HomeItemKind.values.firstWhere(
        (value) => value.name == kind,
        orElse: () =>
            throw FormatException('Unsupported Home item kind: $kind'),
      ),
      episodes: List.unmodifiable(
        episodes.map((episode) => episode.toDomain()),
      ),
    );
  }
}
