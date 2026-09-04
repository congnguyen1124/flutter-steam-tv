// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_section_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeSectionDto _$HomeSectionDtoFromJson(Map<String, dynamic> json) =>
    _HomeSectionDto(
      id: json['id'] as String,
      title: json['title'] as String,
      viewType: json['viewType'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => HomeItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeSectionDtoToJson(_HomeSectionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'viewType': instance.viewType,
      'items': instance.items,
    };
