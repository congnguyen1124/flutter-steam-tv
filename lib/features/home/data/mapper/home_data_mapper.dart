import 'package:flutter_steam_tv/features/home/data/model/home_item_dto.dart';
import 'package:flutter_steam_tv/features/home/data/model/home_section_dto.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';

extension HomeSectionDtoMapper on HomeSectionDto {
  HomeSection toDomain() {
    return HomeSection(
      id: id,
      title: title,
      items: List.unmodifiable(items.map((item) => item.toDomain())),
    );
  }
}

extension on HomeItemDto {
  HomeItem toDomain() {
    return HomeItem(
      id: id,
      title: title,
      description: description,
      kind: HomeItemKind.values.firstWhere(
        (value) => value.name == kind,
        orElse: () => .video,
      ),
    );
  }
}
