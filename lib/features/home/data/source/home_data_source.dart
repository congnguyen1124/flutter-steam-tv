import 'package:flutter_steam_tv/features/home/data/model/home_section_dto.dart';

abstract interface class HomeDataSource {
  Future<List<HomeSectionDto>> fetchHomeSections();
}

final class HomeDummyDataSource implements HomeDataSource {
  const HomeDummyDataSource();

  @override
  Future<List<HomeSectionDto>> fetchHomeSections() async {
    return _sectionsJson.map(HomeSectionDto.fromJson).toList(growable: false);
  }

  static const List<Map<String, Object?>> _sectionsJson = [
    {
      'id': 'featured-today',
      'title': 'Featured today',
      'items': [
        {
          'id': 'opening-night',
          'title': 'Opening Night',
          'description': 'Live coverage from the main arena',
          'kind': 'channel',
        },
        {
          'id': 'wild-frontier',
          'title': 'Wild Frontier',
          'description': 'A journey into untouched landscapes',
          'kind': 'video',
        },
        {
          'id': 'after-the-storm',
          'title': 'After the Storm',
          'description': 'Stories of recovery and resilience',
          'kind': 'series',
        },
      ],
    },
    {
      'id': 'videos-for-you',
      'title': 'Videos for you',
      'items': [
        {
          'id': 'city-lines',
          'title': 'City Lines',
          'description': 'Architecture after dark',
          'kind': 'video',
        },
        {
          'id': 'deep-current',
          'title': 'Deep Current',
          'description': 'Below the surface of the Pacific',
          'kind': 'video',
        },
        {
          'id': 'final-lap',
          'title': 'The Final Lap',
          'description': 'Inside the championship race',
          'kind': 'video',
        },
        {
          'id': 'field-notes',
          'title': 'Field Notes',
          'description': 'Short stories from the road',
          'kind': 'short',
        },
      ],
    },
  ];
}
