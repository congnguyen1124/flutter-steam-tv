import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_item_dto.freezed.dart';
part 'home_item_dto.g.dart';

@freezed
abstract class HomeItemDto with _$HomeItemDto {
  const factory HomeItemDto({
    required String id,
    required String title,
    required String description,
    required String kind,
  }) = _HomeItemDto;

  factory HomeItemDto.fromJson(Map<String, Object?> json) =>
      _$HomeItemDtoFromJson(json);
}
