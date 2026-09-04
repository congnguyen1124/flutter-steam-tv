import 'package:flutter_steam_tv/features/home/data/repository/home_repository_impl.dart';
import 'package:flutter_steam_tv/features/home/data/source/home_dummy_data_source.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/domain/repository/home_repository.dart';
import 'package:flutter_steam_tv/features/player/data/repository/home_catalog_playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolving from the catalogue', () {
    test('a video resolves to its own stream', () async {
      final repository = HomeCatalogPlaybackRepository(
        _FakeHomeRepository(const [
          HomeSection(
            id: 'videos',
            title: 'Videos',
            viewType: .videos,
            items: [
              HomeItem(
                id: 'video-a',
                videoUrl: 'https://cdn.example/a.m3u8',
                trailerUrl: 'https://cdn.example/a-trailer.m3u8',
                title: 'Video A',
                description: 'First',
                kind: .video,
              ),
            ],
          ),
        ]),
      );

      final item = await repository.getPlaybackItem('video-a');

      expect(item.streamUrl, Uri.parse('https://cdn.example/a.m3u8'));
      expect(item.title, 'Video A');
      expect(item.isLive, isFalse);
    });

    test('a channel is live', () async {
      final repository = HomeCatalogPlaybackRepository(
        _FakeHomeRepository(const [
          HomeSection(
            id: 'channels',
            title: 'Channels',
            viewType: .channels,
            items: [
              HomeItem(
                id: 'channel-a',
                videoUrl: 'https://cdn.example/live.m3u8',
                title: 'Channel A',
                description: 'Live',
                kind: .channel,
              ),
            ],
          ),
        ]),
      );

      final item = await repository.getPlaybackItem('channel-a');

      // Derived from the kind, so a row that renders as a channel and a stream that behaves like
      // one cannot disagree. Drives "no seek bar" and "resume at the live edge".
      expect(item.isLive, isTrue);
    });

    test('an episode is reachable by its own id', () async {
      final repository = HomeCatalogPlaybackRepository(_FakeHomeRepository(_seriesSections));

      final item = await repository.getPlaybackItem('episode-2');

      // Episodes are nested, so a search that only looked at top-level items would fail on exactly
      // the items a series exists to offer.
      expect(item.id, 'episode-2');
      expect(item.streamUrl, Uri.parse('https://cdn.example/ep2.m3u8'));
    });

    test('a series with no stream of its own resolves to its first episode', () async {
      final repository = HomeCatalogPlaybackRepository(_FakeHomeRepository(_seriesSections));

      final item = await repository.getPlaybackItem('series-a');

      // Pressing a series means "start watching". Resolving it here is what lets the title block
      // name the episode that is really on screen.
      expect(item.id, 'episode-1');
      expect(item.title, 'Episode 1');
    });

    test('a series with a stream of its own plays that', () async {
      final repository = HomeCatalogPlaybackRepository(
        _FakeHomeRepository(const [
          HomeSection(
            id: 'series',
            title: 'Series',
            viewType: .listSeries,
            items: [
              HomeItem(
                id: 'series-b',
                videoUrl: 'https://cdn.example/series-b.m3u8',
                title: 'Series B',
                description: 'Has a feature of its own',
                kind: .series,
                episodes: [
                  HomeItem(
                    id: 'episode-b-1',
                    videoUrl: 'https://cdn.example/ep-b1.m3u8',
                    title: 'Episode 1',
                    description: 'First',
                    kind: .video,
                  ),
                ],
              ),
            ],
          ),
        ]),
      );

      final item = await repository.getPlaybackItem('series-b');

      expect(item.id, 'series-b');
    });

    test('the trailer stands in when the main stream is missing', () async {
      final repository = HomeCatalogPlaybackRepository(
        _FakeHomeRepository(const [
          HomeSection(
            id: 'videos',
            title: 'Videos',
            viewType: .videos,
            items: [
              HomeItem(
                id: 'video-trailer-only',
                trailerUrl: 'https://cdn.example/trailer.m3u8',
                title: 'Trailer only',
                description: 'No feature yet',
                kind: .video,
              ),
            ],
          ),
        ]),
      );

      final item = await repository.getPlaybackItem('video-trailer-only');

      // Something beats a black screen. Never the other way round — a viewer who pressed play
      // wants the film, so the trailer is only ever the fallback.
      expect(item.streamUrl, Uri.parse('https://cdn.example/trailer.m3u8'));
    });
  });

  group('failures name the item', () {
    test('an unknown id fails with the id in the message', () async {
      final repository = HomeCatalogPlaybackRepository(_FakeHomeRepository(const []));

      await expectLater(
        repository.getPlaybackItem('nope'),
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('nope'))),
      );
    });

    test('an item with nothing to play fails rather than opening a black player', () async {
      final repository = HomeCatalogPlaybackRepository(
        _FakeHomeRepository(const [
          HomeSection(
            id: 'videos',
            title: 'Videos',
            viewType: .videos,
            items: [
              HomeItem(
                id: 'video-empty',
                title: 'Nothing to play',
                description: 'No urls at all',
                kind: .video,
              ),
            ],
          ),
        ]),
      );

      await expectLater(
        repository.getPlaybackItem('video-empty'),
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('video-empty'))),
      );
    });
  });

  group('against the real catalogue', () {
    test('every item Home can offer is playable', () async {
      // The regression this exists for: the player used to keep a catalogue of its own, and when
      // Home's ids changed, every press opened a player that could not resolve its own item. This
      // walks what Home actually serves, so that cannot come back silently.
      const home = HomeRepositoryImpl(HomeDummyDataSource());
      final repository = HomeCatalogPlaybackRepository(home);
      final sections = await home.getHomeSections();

      final ids = <String>[];
      for (final section in sections) {
        for (final item in section.items) {
          ids.add(item.id);
          ids.addAll(item.episodes.map((episode) => episode.id));
        }
      }

      expect(ids, isNotEmpty);
      for (final id in ids) {
        final item = await repository.getPlaybackItem(id);
        expect(item.streamUrl.hasScheme, isTrue, reason: id);
      }
    });

    test('a live channel from the real catalogue reports itself live', () async {
      const home = HomeRepositoryImpl(HomeDummyDataSource());
      final repository = HomeCatalogPlaybackRepository(home);
      final sections = await home.getHomeSections();
      final channel = sections
          .firstWhere((section) => section.viewType == HomeSectionViewType.channels)
          .items
          .first;

      final item = await repository.getPlaybackItem(channel.id);

      expect(item.isLive, isTrue);
    });
  });
}

const _seriesSections = [
  HomeSection(
    id: 'series',
    title: 'Series',
    viewType: .listSeries,
    items: [
      HomeItem(
        id: 'series-a',
        title: 'Series A',
        description: 'No stream of its own',
        kind: .series,
        episodes: [
          HomeItem(
            id: 'episode-1',
            videoUrl: 'https://cdn.example/ep1.m3u8',
            title: 'Episode 1',
            description: 'First',
            kind: .video,
          ),
          HomeItem(
            id: 'episode-2',
            videoUrl: 'https://cdn.example/ep2.m3u8',
            title: 'Episode 2',
            description: 'Second',
            kind: .video,
          ),
        ],
      ),
    ],
  ),
];

final class _FakeHomeRepository implements HomeRepository {
  const _FakeHomeRepository(this._sections);

  final List<HomeSection> _sections;

  @override
  Future<List<HomeSection>> getHomeSections() async => _sections;
}
