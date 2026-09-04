// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeItemDto _$HomeItemDtoFromJson(Map<String, dynamic> json) => _HomeItemDto(
  id: json['id'] as String,
  videoUrl: json['videoUrl'] as String? ?? '',
  trailerUrl: json['trailerUrl'] as String? ?? '',
  thumbnailUrl: json['thumbnailUrl'] as String,
  vastUrl: json['vastUrl'] as String? ?? '',
  title: json['title'] as String,
  description: json['description'] as String,
  ageRestriction: json['ageRestriction'] as String?,
  logoUrl: json['logoUrl'] as String? ?? '',
  kind: json['kind'] as String,
  episodes:
      (json['episodes'] as List<dynamic>?)
          ?.map((e) => HomeItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HomeItemDto>[],
);

Map<String, dynamic> _$HomeItemDtoToJson(_HomeItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'videoUrl': instance.videoUrl,
      'trailerUrl': instance.trailerUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'vastUrl': instance.vastUrl,
      'title': instance.title,
      'description': instance.description,
      'ageRestriction': instance.ageRestriction,
      'logoUrl': instance.logoUrl,
      'kind': instance.kind,
      'episodes': instance.episodes,
    };
