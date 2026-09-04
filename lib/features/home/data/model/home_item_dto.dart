import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_item_dto.freezed.dart';
part 'home_item_dto.g.dart';

@freezed
abstract class HomeItemDto with _$HomeItemDto {
  const factory HomeItemDto({
    required String id,
    @Default('') String videoUrl,
    @Default('') String trailerUrl,
    required String thumbnailUrl,
    @Default('') String vastUrl,
    required String title,
    required String description,
    String? ageRestriction,
    @Default('') String logoUrl,
    required String kind,
    @Default(<HomeItemDto>[]) List<HomeItemDto> episodes,
  }) = _HomeItemDto;

  factory HomeItemDto.fromJson(Map<String, Object?> json) =>
      _$HomeItemDtoFromJson(json);
}
