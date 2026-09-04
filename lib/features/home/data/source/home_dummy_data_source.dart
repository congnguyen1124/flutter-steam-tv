import 'package:flutter_steam_tv/features/home/data/model/home_item_dto.dart';
import 'package:flutter_steam_tv/features/home/data/model/home_section_dto.dart';
import 'package:flutter_steam_tv/features/home/data/source/home_data_source.dart';

final class HomeDummyDataSource implements HomeDataSource {
  const HomeDummyDataSource();

  @override
  Future<List<HomeSectionDto>> fetchHomeSections() async {
    final featuredVideos = _featuredVideos;
    final discoveryShorts = _discoveryShorts;

    return List.unmodifiable([
      HomeSectionDto(
        id: 'featured-stories',
        title: 'Featured today',
        viewType: 'banner',
        items: featuredVideos,
      ),
      HomeSectionDto(
        id: 'videos-for-you',
        title: 'Videos for you',
        viewType: 'videos',
        items: featuredVideos.reversed.toList(growable: false),
      ),
      HomeSectionDto(
        id: 'popular-videos',
        title: 'Popular videos',
        viewType: 'videosPopular',
        items: featuredVideos,
      ),
      HomeSectionDto(
        id: 'documentary-series',
        title: 'Documentary series',
        viewType: 'listSeries',
        items: _documentarySeries,
      ),
      HomeSectionDto(
        id: 'live-channels',
        title: 'Live channels',
        viewType: 'channels',
        items: _liveChannels,
      ),
      HomeSectionDto(
        id: 'portrait-discovery',
        title: 'Portrait discoveries',
        viewType: 'verticalBanner',
        items: discoveryShorts,
      ),
      HomeSectionDto(
        id: 'shorts-feed',
        title: 'Fresh shorts',
        viewType: 'shorts',
        items: discoveryShorts.reversed.toList(growable: false),
      ),
      HomeSectionDto(
        id: 'popular-shorts',
        title: 'Popular shorts',
        viewType: 'shortPopular',
        items: discoveryShorts,
      ),
    ]);
  }

  static List<HomeItemDto> get _featuredVideos => [
    _item(
      id: 'video-basketball-energy',
      videoUrl: _StreamUrls.appleBipBopTs,
      trailerUrl: _StreamUrls.appleBipBopFmp4,
      thumbnailUrl: _Images.basketball,
      title: 'Pulse of the court',
      description:
          'Follow two athletes through a basketball game charged with speed, focus, and emotion.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'video-wild-tiger',
      videoUrl: _StreamUrls.tearsOfSteelTs,
      trailerUrl: _StreamUrls.appleHevc,
      thumbnailUrl: _Images.tigerForest,
      title: 'Realm of the Bengal tiger',
      description:
          "A quiet journey through Ranthambore and the hidden world of one of Asia's great predators.",
      ageRestriction: 'T13',
    ),
    _item(
      id: 'video-tokyo-culture',
      videoUrl: _StreamUrls.bigBuckBunnyAbr,
      trailerUrl: _StreamUrls.tearsOfSteelTs,
      thumbnailUrl: _Images.tokyoStreet,
      title: 'Tokyo: Tradition in motion',
      description:
          'Explore Asakusa, where kimonos, ancient temples, and modern city life meet.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'video-chinese-festival',
      videoUrl: _StreamUrls.tearsOfSteelFmp4,
      trailerUrl: _StreamUrls.bigBuckBunnyAbr,
      thumbnailUrl: _Images.chineseFestival,
      title: 'Colors of a Chinese festival',
      description:
          'Vivid costumes, music, and community rituals bring a traditional celebration to life.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'video-football-decision',
      videoUrl: _StreamUrls.appleBipBopFmp4,
      trailerUrl: _StreamUrls.shakaAngelOne,
      thumbnailUrl: _Images.football,
      title: 'The decisive touch',
      description:
          'A football match turns on one perfectly timed run and a fearless finish.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'video-cricket-pressure',
      videoUrl: _StreamUrls.appleHevc,
      trailerUrl: _StreamUrls.bitmovinSintel,
      thumbnailUrl: _Images.cricket,
      title: 'Under pressure at the crease',
      description:
          'A batter prepares for the delivery that could decide the entire match.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'video-lunar-new-year',
      videoUrl: _StreamUrls.shakaAngelOne,
      trailerUrl: _StreamUrls.appleBipBopTs,
      thumbnailUrl: _Images.chineseNewYear,
      title: 'Welcoming the new spring',
      description:
          'Red, gold, and generations of tradition fill a joyful Lunar New Year celebration.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'video-japanese-ceremony',
      videoUrl: _StreamUrls.bitmovinSintel,
      trailerUrl: _StreamUrls.appleBipBopFmp4,
      thumbnailUrl: _Images.japaneseCeremony,
      title: 'Grace in every gesture',
      description:
          'A close look at the details, discipline, and meaning of a Japanese ceremony.',
      ageRestriction: 'P',
    ),
  ];

  static List<HomeItemDto> get _discoveryShorts => [
    _item(
      id: 'short-cricket-focus',
      kind: 'short',
      videoUrl: _StreamUrls.jwPlayerBigBuckBunny,
      trailerUrl: _StreamUrls.appleHevc,
      thumbnailUrl: _Images.cricket,
      title: 'Before the strike',
      description:
          'A cricket player finds complete focus just before the game begins.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'short-lunar-new-year',
      kind: 'short',
      videoUrl: _StreamUrls.longtailBipBop,
      trailerUrl: _StreamUrls.tearsOfSteelTs,
      thumbnailUrl: _Images.chineseNewYear,
      title: 'A spring in red and gold',
      description:
          'Lunar New Year comes alive among lanterns and traditional dress.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'short-japanese-ceremony',
      kind: 'short',
      videoUrl: _StreamUrls.muxTest001,
      trailerUrl: _StreamUrls.tearsOfSteelFmp4,
      thumbnailUrl: _Images.japaneseCeremony,
      title: 'A Japanese ceremony',
      description:
          'Intricate clothing and timeless gestures shape a traditional ceremony.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'short-tiger-portrait',
      kind: 'short',
      videoUrl: _StreamUrls.bigBuckBunnyFixed,
      trailerUrl: _StreamUrls.bigBuckBunnyAbr,
      thumbnailUrl: _Images.tigerPortrait,
      title: 'The wild gaze',
      description:
          "A close portrait captures a tiger's quiet power among autumn leaves.",
      ageRestriction: 'T13',
    ),
    _item(
      id: 'short-football-motion',
      kind: 'short',
      videoUrl: _StreamUrls.muxPtsShift,
      trailerUrl: _StreamUrls.shakaAngelOne,
      thumbnailUrl: _Images.football,
      title: 'Motion on the pitch',
      description:
          'One decisive touch in a football match played at full speed.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'short-basketball-reach',
      kind: 'short',
      videoUrl: _StreamUrls.muxSampleAes,
      trailerUrl: _StreamUrls.bitmovinSintel,
      thumbnailUrl: _Images.basketball,
      title: 'Above the rim',
      description:
          'Two players rise for a split-second contest above the basket.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'short-tokyo-walk',
      kind: 'short',
      videoUrl: _StreamUrls.muxIssue666,
      trailerUrl: _StreamUrls.appleBipBopTs,
      thumbnailUrl: _Images.tokyoStreet,
      title: 'A minute in old Tokyo',
      description:
          'A quick walk through Asakusa where every corner holds a story.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'short-festival-colors',
      kind: 'short',
      videoUrl: _StreamUrls.bigBuckBunnyAbr,
      trailerUrl: _StreamUrls.appleBipBopFmp4,
      thumbnailUrl: _Images.chineseFestival,
      title: 'Festival colors',
      description:
          'Traditional costumes sweep past the camera in a burst of color.',
      ageRestriction: 'P',
    ),
  ];

  static List<HomeItemDto> get _documentarySeries => [
    _item(
      id: 'series-wild-asia',
      kind: 'series',
      videoUrl: _StreamUrls.appleBipBopTs,
      trailerUrl: _StreamUrls.appleHevc,
      thumbnailUrl: _Images.tigerForest,
      title: 'Wild Asia',
      description:
          "A documentary series about Asia's landscapes and remarkable wildlife.",
      ageRestriction: 'T13',
      episodes: [
        _item(
          id: 'episode-wild-asia-1',
          videoUrl: _StreamUrls.appleBipBopTs,
          trailerUrl: _StreamUrls.tearsOfSteelTs,
          thumbnailUrl: _Images.tigerForest,
          title: 'Episode 1: Predator of the forest',
          description: 'Track a Bengal tiger through its natural habitat.',
          ageRestriction: 'T13',
        ),
        _item(
          id: 'episode-wild-asia-2',
          videoUrl: _StreamUrls.tearsOfSteelTs,
          trailerUrl: _StreamUrls.tearsOfSteelFmp4,
          thumbnailUrl: _Images.tigerPortrait,
          title: 'Episode 2: Built to survive',
          description:
              'The adaptations that help large animals endure a demanding wilderness.',
          ageRestriction: 'T13',
        ),
      ],
    ),
    _item(
      id: 'series-east-asia-culture',
      kind: 'series',
      videoUrl: _StreamUrls.tearsOfSteelTs,
      trailerUrl: _StreamUrls.bigBuckBunnyAbr,
      thumbnailUrl: _Images.tokyoStreet,
      title: 'Living heritage of East Asia',
      description: 'Meet the people and living traditions of China and Japan.',
      ageRestriction: 'P',
      episodes: [
        _item(
          id: 'episode-east-asia-1',
          videoUrl: _StreamUrls.bigBuckBunnyAbr,
          trailerUrl: _StreamUrls.shakaAngelOne,
          thumbnailUrl: _Images.chineseFestival,
          title: 'Episode 1: Colors of China',
          description: 'A day inside a vibrant traditional festival.',
          ageRestriction: 'P',
        ),
        _item(
          id: 'episode-east-asia-2',
          videoUrl: _StreamUrls.tearsOfSteelFmp4,
          trailerUrl: _StreamUrls.bitmovinSintel,
          thumbnailUrl: _Images.tokyoStreet,
          title: 'Episode 2: Old Tokyo',
          description: 'Asakusa through the eyes of the people who live there.',
          ageRestriction: 'P',
        ),
      ],
    ),
    _item(
      id: 'series-human-performance',
      kind: 'series',
      videoUrl: _StreamUrls.bigBuckBunnyAbr,
      trailerUrl: _StreamUrls.appleBipBopTs,
      thumbnailUrl: _Images.basketball,
      title: 'The edge of performance',
      description:
          'Athletes reveal how preparation becomes instinct when the pressure rises.',
      ageRestriction: 'P',
      episodes: [
        _item(
          id: 'episode-performance-1',
          videoUrl: _StreamUrls.appleBipBopFmp4,
          trailerUrl: _StreamUrls.appleHevc,
          thumbnailUrl: _Images.basketball,
          title: 'Episode 1: Reading the court',
          description:
              'Basketball players make complex decisions in fractions of a second.',
          ageRestriction: 'P',
        ),
        _item(
          id: 'episode-performance-2',
          videoUrl: _StreamUrls.appleHevc,
          trailerUrl: _StreamUrls.tearsOfSteelTs,
          thumbnailUrl: _Images.football,
          title: 'Episode 2: Space and timing',
          description:
              'A football attack is built from movement before the ball arrives.',
          ageRestriction: 'P',
        ),
      ],
    ),
    _item(
      id: 'series-rituals-of-asia',
      kind: 'series',
      videoUrl: _StreamUrls.tearsOfSteelFmp4,
      trailerUrl: _StreamUrls.bigBuckBunnyAbr,
      thumbnailUrl: _Images.japaneseCeremony,
      title: 'Rituals of Asia',
      description:
          'A respectful journey through ceremonies that connect past and present.',
      ageRestriction: 'P',
      episodes: [
        _item(
          id: 'episode-rituals-1',
          videoUrl: _StreamUrls.shakaAngelOne,
          trailerUrl: _StreamUrls.bitmovinSintel,
          thumbnailUrl: _Images.japaneseCeremony,
          title: 'Episode 1: A language of gestures',
          description:
              'Every movement carries meaning in a traditional Japanese ceremony.',
          ageRestriction: 'P',
        ),
        _item(
          id: 'episode-rituals-2',
          videoUrl: _StreamUrls.bitmovinSintel,
          trailerUrl: _StreamUrls.appleBipBopTs,
          thumbnailUrl: _Images.chineseNewYear,
          title: 'Episode 2: The color of renewal',
          description:
              'Families welcome a new year through symbols of luck and renewal.',
          ageRestriction: 'P',
        ),
        _item(
          id: 'episode-rituals-3',
          videoUrl: _StreamUrls.muxImscCaptions,
          trailerUrl: _StreamUrls.appleBipBopFmp4,
          thumbnailUrl: _Images.chineseFestival,
          title: 'Episode 3: A community in celebration',
          description:
              'Music and costume transform a gathering into shared memory.',
          ageRestriction: 'P',
        ),
      ],
    ),
  ];

  static List<HomeItemDto> get _liveChannels => [
    _item(
      id: 'channel-sport-live',
      kind: 'channel',
      videoUrl: _StreamUrls.akamaiLive,
      trailerUrl: _StreamUrls.appleHevc,
      thumbnailUrl: _Images.basketball,
      title: 'StreamTV Sport',
      description: "The day's biggest sporting moments, live every day.",
      ageRestriction: 'P',
    ),
    _item(
      id: 'channel-nature-live',
      kind: 'channel',
      videoUrl: _StreamUrls.shakaLive,
      trailerUrl: _StreamUrls.tearsOfSteelTs,
      thumbnailUrl: _Images.tigerForest,
      title: 'StreamTV Nature',
      description: 'An uninterrupted window into the wild, 24/7.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'channel-football-live',
      kind: 'channel',
      videoUrl: _StreamUrls.akamaiEightLive,
      trailerUrl: _StreamUrls.tearsOfSteelFmp4,
      thumbnailUrl: _Images.football,
      title: 'StreamTV Football',
      description:
          'Live matches, tactical analysis, and the stories behind the final score.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'channel-cricket-live',
      kind: 'channel',
      videoUrl: _StreamUrls.akamaiLive,
      trailerUrl: _StreamUrls.bigBuckBunnyAbr,
      thumbnailUrl: _Images.cricket,
      title: 'StreamTV Cricket',
      description:
          'International cricket and classic matches throughout the day.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'channel-culture-live',
      kind: 'channel',
      videoUrl: _StreamUrls.shakaLive,
      trailerUrl: _StreamUrls.shakaAngelOne,
      thumbnailUrl: _Images.chineseFestival,
      title: 'StreamTV Culture',
      description:
          'Festivals, art, food, and living traditions from around the world.',
      ageRestriction: 'P',
    ),
    _item(
      id: 'channel-city-live',
      kind: 'channel',
      videoUrl: _StreamUrls.akamaiEightLive,
      trailerUrl: _StreamUrls.bitmovinSintel,
      thumbnailUrl: _Images.tokyoStreet,
      title: 'StreamTV Cities',
      description:
          'A continuous window into the streets and rhythms of remarkable cities.',
      ageRestriction: 'P',
    ),
  ];

  static HomeItemDto _item({
    required String id,
    required String videoUrl,
    required String trailerUrl,
    required String thumbnailUrl,
    required String title,
    required String description,
    required String ageRestriction,
    String kind = 'video',
    List<HomeItemDto> episodes = const [],
  }) {
    return HomeItemDto(
      id: id,
      videoUrl: videoUrl,
      trailerUrl: trailerUrl,
      thumbnailUrl: thumbnailUrl,
      title: title,
      description: description,
      ageRestriction: ageRestriction,
      kind: kind,
      episodes: episodes,
    );
  }
}

abstract final class _Images {
  static const String basketball =
      'https://images.pexels.com/photos/9839903/pexels-photo-9839903.jpeg?auto=compress&cs=tinysrgb&w=1600';
  static const String football =
      'https://images.pexels.com/photos/36958062/pexels-photo-36958062.jpeg?auto=compress&cs=tinysrgb&w=1600';
  static const String cricket =
      'https://images.pexels.com/photos/11023865/pexels-photo-11023865.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String tigerForest =
      'https://images.pexels.com/photos/25785873/pexels-photo-25785873.jpeg?auto=compress&cs=tinysrgb&w=1600';
  static const String tigerPortrait =
      'https://images.pexels.com/photos/12167844/pexels-photo-12167844.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String chineseFestival =
      'https://images.pexels.com/photos/30765119/pexels-photo-30765119/free-photo-of-vibrant-traditional-chinese-cultural-festival.jpeg?auto=compress&cs=tinysrgb&w=1600';
  static const String chineseNewYear =
      'https://images.pexels.com/photos/36603900/pexels-photo-36603900.jpeg?auto=compress&cs=tinysrgb&w=1200';
  static const String tokyoStreet =
      'https://images.pexels.com/photos/12343886/pexels-photo-12343886.jpeg?auto=compress&cs=tinysrgb&w=1600';
  static const String japaneseCeremony =
      'https://images.pexels.com/photos/31370378/pexels-photo-31370378.jpeg?auto=compress&cs=tinysrgb&w=1200';
}

abstract final class _StreamUrls {
  static const String appleBipBopTs =
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8';
  static const String appleBipBopFmp4 =
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8';
  static const String appleHevc =
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8';
  static const String tearsOfSteelTs =
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8';
  static const String tearsOfSteelFmp4 =
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8';
  static const String bigBuckBunnyAbr =
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
  static const String bigBuckBunnyFixed =
      'https://test-streams.mux.dev/x36xhzz/url_6/193039199_mp4_h264_aac_hq_7.m3u8';
  static const String muxPtsShift =
      'https://test-streams.mux.dev/pts_shift/master.m3u8';
  static const String muxImscCaptions =
      'https://test-streams.mux.dev/tos_ismc/main.m3u8';
  static const String muxTest001 =
      'https://test-streams.mux.dev/test_001/stream.m3u8';
  static const String muxIssue666 =
      'https://test-streams.mux.dev/issue666/playlists/cisq0gim60007xzvi505emlxx.m3u8';
  static const String muxSampleAes =
      'https://test-streams.mux.dev/bbbAES/playlists/sample_aes/index.m3u8';
  static const String jwPlayerBigBuckBunny =
      'https://cdn.jwplayer.com/manifests/pZxWPRg4.m3u8';
  static const String longtailBipBop =
      'https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8';
  static const String shakaAngelOne =
      'https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8';
  static const String bitmovinSintel =
      'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8';
  static const String akamaiLive =
      'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8';
  static const String akamaiEightLive =
      'https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8';
  static const String shakaLive =
      'https://storage.googleapis.com/shaka-live-assets/player-source.m3u8';
}
