import 'package:flutter_steam_tv/features/home/data/source/home_dummy_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns the Android reference sections in editorial order', () async {
    const dataSource = HomeDummyDataSource();

    final sections = await dataSource.fetchHomeSections();

    expect(sections.map((section) => section.viewType), [
      'banner',
      'videos',
      'videosPopular',
      'listSeries',
      'channels',
      'verticalBanner',
      'shorts',
      'shortPopular',
    ]);
    expect(sections.map((section) => section.items.length), [
      8,
      8,
      8,
      4,
      6,
      8,
      8,
      8,
    ]);
    expect(sections.first.items.first.id, 'video-basketball-energy');
    expect(sections[1].items.first.id, 'video-japanese-ceremony');
    expect(sections[3].items.first.episodes, hasLength(2));
    expect(sections[4].items.first.kind, 'channel');
  });
}
