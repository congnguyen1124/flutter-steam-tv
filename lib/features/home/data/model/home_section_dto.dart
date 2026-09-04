import 'package:flutter_steam_tv/features/home/data/model/home_item_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_section_dto.freezed.dart';
part 'home_section_dto.g.dart';

@freezed
abstract class HomeSectionDto with _$HomeSectionDto {
  const factory HomeSectionDto({
    required String id,
    required String title,
    required List<HomeItemDto> items,
  }) = _HomeSectionDto;

  factory HomeSectionDto.fromJson(Map<String, Object?> json) =>
      _$HomeSectionDtoFromJson(json);
}
