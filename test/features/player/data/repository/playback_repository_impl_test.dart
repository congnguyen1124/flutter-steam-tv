import 'package:flutter_steam_tv/features/player/data/model/playback_item_data.dart';
import 'package:flutter_steam_tv/features/player/data/repository/playback_repository_impl.dart';
import 'package:flutter_steam_tv/features/player/data/source/playback_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackRepositoryImpl', () {
    test('maps the transport model to a domain item with a parsed url', () async {
      final repository = PlaybackRepositoryImpl(
        dataSource: _FakeDataSource(
          const PlaybackItemData(
            id: 'wild-frontier',
            title: 'Wild Frontier',
            description: 'A journey into untouched landscapes',
            streamUrl: 'https://cdn.example/a.m3u8',
            isLive: false,
          ),
        ),
      );

      final item = await repository.getPlaybackItem('wild-frontier');

      expect(item.title, 'Wild Frontier');
      expect(item.streamUrl.host, 'cdn.example');
      expect(item.isLive, isFalse);
    });

    test('an unknown id fails with the id in the message', () async {
      final repository = PlaybackRepositoryImpl(dataSource: _FakeDataSource(null));

      // A `StateError` so the route renders its startup-error state and the log names the item that
      // could not be resolved.
      await expectLater(
        repository.getPlaybackItem('nope'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', contains('nope')),
        ),
      );
    });
  });

  group('PlaybackDummyDataSource', () {
    test('resolves every id the home catalogue can hand out', () async {
      const source = PlaybackDummyDataSource();

      // These ids come from HomeDummyDataSource. A home item that cannot be played is a dead card,
      // so the two lists have to stay in step.
      for (final id in <String>[
        'opening-night',
        'wild-frontier',
        'after-the-storm',
        'city-lines',
        'deep-current',
        'final-lap',
      ]) {
        expect(await source.fetchPlaybackItem(id), isNotNull, reason: id);
      }
    });

    test('an unknown id resolves to nothing', () async {
      const source = PlaybackDummyDataSource();

      expect(await source.fetchPlaybackItem('missing'), isNull);
    });
  });
}

final class _FakeDataSource implements PlaybackDataSource {
  const _FakeDataSource(this._item);

  final PlaybackItemData? _item;

  @override
  Future<PlaybackItemData?> fetchPlaybackItem(String itemId) async => _item;
}
