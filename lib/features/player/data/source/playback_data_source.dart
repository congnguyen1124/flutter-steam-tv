import 'package:flutter_steam_tv/features/player/data/model/playback_item_data.dart';

/// Where playable items come from.
abstract interface class PlaybackDataSource {
  /// Returns the item for [itemId], or null when the catalogue has no such id.
  Future<PlaybackItemData?> fetchPlaybackItem(String itemId);
}

/// The in-app catalogue, matching the ids `HomeDummyDataSource` hands out.
///
/// ## Why the ids are duplicated here
///
/// Home items carry no stream URL — nothing on the home screen plays — so playback has to resolve
/// one. Doing it in a player-owned source rather than widening `HomeItem` keeps the home feature
/// unaware of playback, which is the direction the dependency should point: several surfaces will
/// eventually start playback, and none of them should have to carry a URL through their own models
/// to do it.
///
/// The streams are the same public test manifests the native Android TV app uses, so a stream that
/// misbehaves can be compared across both apps. Live entries exist on purpose: they are the only
/// way to exercise the no-seek-bar path and the resume-at-live-edge toggle.
final class PlaybackDummyDataSource implements PlaybackDataSource {
  /// Builds the in-app catalogue.
  const PlaybackDummyDataSource();

  @override
  Future<PlaybackItemData?> fetchPlaybackItem(String itemId) async => _catalogue[itemId];

  static const String _appleBase =
      'https://devstreaming-cdn.apple.com/videos/streaming/examples/';
  static const String _muxBase = 'https://test-streams.mux.dev/';
  static const String _unifiedBase =
      'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/';

  static const Map<String, PlaybackItemData> _catalogue = {
    'opening-night': PlaybackItemData(
      id: 'opening-night',
      title: 'Opening Night',
      description: 'Live coverage from the main arena',
      streamUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
      isLive: true,
    ),
    'wild-frontier': PlaybackItemData(
      id: 'wild-frontier',
      title: 'Wild Frontier',
      description: 'A journey into untouched landscapes',
      streamUrl: '${_unifiedBase}tears-of-steel.ism/.m3u8',
      isLive: false,
    ),
    'after-the-storm': PlaybackItemData(
      id: 'after-the-storm',
      title: 'After the Storm',
      description: 'Stories of recovery and resilience',
      streamUrl: '${_appleBase}img_bipbop_adv_example_ts/master.m3u8',
      isLive: false,
    ),
    'city-lines': PlaybackItemData(
      id: 'city-lines',
      title: 'City Lines',
      description: 'Architecture after dark',
      streamUrl: '${_muxBase}x36xhzz/x36xhzz.m3u8',
      isLive: false,
    ),
    'deep-current': PlaybackItemData(
      id: 'deep-current',
      title: 'Deep Current',
      description: 'Below the surface of the Pacific',
      streamUrl: 'https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8',
      isLive: false,
    ),
    'final-lap': PlaybackItemData(
      id: 'final-lap',
      title: 'The Final Lap',
      description: 'Inside the championship race',
      streamUrl: 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
      isLive: false,
    ),
  };
}
