import 'package:flutter_steam_tv/features/home/data/model/home_item_dto.dart';
import 'package:flutter_steam_tv/features/home/data/model/home_section_dto.dart';
import 'package:flutter_steam_tv/features/home/data/repository/home_repository_impl.dart';
import 'package:flutter_steam_tv/features/home/data/source/home_data_source.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps data source DTOs to domain models', () async {
    const repository = HomeRepositoryImpl(_FakeHomeDataSource());

    final sections = await repository.getHomeSections();

    expect(sections, hasLength(1));
    expect(sections.single.title, 'Featured');
    expect(sections.single.viewType, HomeSectionViewType.banner);
    expect(sections.single.items.single.kind, HomeItemKind.video);
    expect(sections.single.items.single.videoUrl, 'https://example.test/video');
  });

  test('rejects content that does not match its section view type', () async {
    const repository = HomeRepositoryImpl(_InvalidHomeDataSource());

    expect(repository.getHomeSections, throwsA(isA<StateError>()));
  });
}

final class _FakeHomeDataSource implements HomeDataSource {
  const _FakeHomeDataSource();

  @override
  Future<List<HomeSectionDto>> fetchHomeSections() async {
    return const [
      HomeSectionDto(
        id: 'featured',
        title: 'Featured',
        viewType: 'banner',
        items: [
          HomeItemDto(
            id: 'video-1',
            videoUrl: 'https://example.test/video',
            thumbnailUrl: 'https://example.test/image',
            title: 'Video',
            description: 'Description',
            kind: 'video',
          ),
        ],
      ),
    ];
  }
}

final class _InvalidHomeDataSource implements HomeDataSource {
  const _InvalidHomeDataSource();

  @override
  Future<List<HomeSectionDto>> fetchHomeSections() async {
    return const [
      HomeSectionDto(
        id: 'invalid-banner',
        title: 'Invalid',
        viewType: 'banner',
        items: [
          HomeItemDto(
            id: 'short-1',
            thumbnailUrl: 'https://example.test/image',
            title: 'Short',
            description: 'Description',
            kind: 'short',
          ),
        ],
      ),
    ];
  }
}
