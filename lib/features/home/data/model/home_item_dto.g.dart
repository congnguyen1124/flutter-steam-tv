// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeItemDto _$HomeItemDtoFromJson(Map<String, dynamic> json) => _HomeItemDto(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  kind: json['kind'] as String,
);

Map<String, dynamic> _$HomeItemDtoToJson(_HomeItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'kind': instance.kind,
    };
