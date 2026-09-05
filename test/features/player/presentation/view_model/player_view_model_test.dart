import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/domain/repository/playback_repository.dart';
import 'package:flutter_steam_tv/features/player/player_providers.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/view_model/player_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_player/stream_player.dart';

/// The whole open-the-player flow, with a fake native host.
///
/// This is the part that broke silently once already: the player kept a catalogue of its own, Home's
/// ids changed, and every press opened a player that could not resolve its item. Nothing in the
/// widget tree would have caught it, so the flow is pinned here instead — item resolution, player
/// creation, the load/prepare/play sequence, state folding and teardown.
///
/// No channel, no plugin, no device: `StreamPlayerPlatform` is one small class, so a fake host is
/// the whole setup.
void main() {
  late _FakeStreamPlayerHost host;

  setUp(() {
    host = _FakeStreamPlayerHost();
    StreamPlayerPlatform.instance = host;
  });

  tearDown(StreamPlayerPlatform.resetInstanceForTesting);

  group('opening an item', () {
    test('resolves the item, then loads, prepares and plays it', () async {
      final container = _container(_vodItem);
      addTearDown(container.dispose);

      final uiState = await _open(container, 'video-a');

      expect(uiState.item.title, 'Video A');
      expect(
        host.commands.map((command) => command.runtimeType).toList(),
        <Type>[StreamPlayerLoad, StreamPlayerPrepare, StreamPlayerPlay],
      );
      final load = host.commands.first as StreamPlayerLoad;
      expect(load.uri, Uri.parse('https://cdn.example/a.m3u8'));
    });

    test('the player is created only after the item resolves', () async {
      // Ordering matters: a catalogue miss must not leave a hardware decoder allocated for a
      // screen that is about to render an error instead of video.
      final container = _container(_failingRepository);
      addTearDown(container.dispose);

      await expectLater(
        container.read(playerViewModelProvider('nope').future),
        throwsStateError,
      );
      expect(host.createdPlayers, isEmpty);
    });

    test(
      'a live item is marked live, so the screen drops its seek bar',
      () async {
        final container = _container(_liveItem);
        addTearDown(container.dispose);

        final uiState = await _open(container, 'channel-a');

        expect(uiState.item.isLive, isTrue);
        expect(uiState.isSeekable, isFalse);
      },
    );
  });

  group('state folding', () {
    test('host facts reach the screen state', () async {
      final container = _container(_vodItem);
      addTearDown(container.dispose);
      await _open(container, 'video-a');

      host.emit(const StreamPlayerIsPlayingChanged(true));
      host.emit(
        const StreamPlayerProgressChanged(
          position: Duration(seconds: 30),
          bufferedPosition: Duration(seconds: 60),
          duration: Duration(seconds: 120),
        ),
      );
      await pumpEventQueue();

      final uiState = container
          .read(playerViewModelProvider('video-a'))
          .requireValue;
      expect(uiState.isPlaying, isTrue);
      expect(uiState.progressFraction, 0.25);
      expect(uiState.bufferedFraction, 0.5);
    });

    test('a playback failure becomes copy the viewer can read', () async {
      final container = _container(_vodItem);
      addTearDown(container.dispose);
      await _open(container, 'video-a');

      host.emit(
        const StreamPlayerErrorOccurred(
          StreamPlayerNotEntitledError(message: 'HTTP 403'),
        ),
      );
      await pumpEventQueue();

      final uiState = container
          .read(playerViewModelProvider('video-a'))
          .requireValue;
      expect(uiState.error, isNotNull);
      expect(uiState.error!.isRetryable, isFalse);
      // The host owns the diagnosis, the app owns the words. A raw status code on screen is the
      // failure this split exists to prevent.
      expect(uiState.error!.message, isNot(contains('403')));
    });
  });

  group('actions', () {
    test('an on-demand item toggles in place', () async {
      final container = _container(_vodItem);
      addTearDown(container.dispose);
      await _open(container, 'video-a');
      host.commands.clear();

      await container
          .read(playerViewModelProvider('video-a').notifier)
          .togglePlayPause();

      expect(host.commands.single, isA<StreamPlayerTogglePlayPause>());
    });

    test('a live item resumes at the live edge', () async {
      final container = _container(_liveItem);
      addTearDown(container.dispose);
      await _open(container, 'channel-a');
      host.commands.clear();

      await container
          .read(playerViewModelProvider('channel-a').notifier)
          .togglePlayPause();

      // Resuming where the viewer paused silently puts them behind the broadcast with no way back.
      expect(
        host.commands.single,
        isA<StreamPlayerTogglePlayPauseAtDefaultPosition>(),
      );
    });

    test('retry re-prepares and plays', () async {
      final container = _container(_vodItem);
      addTearDown(container.dispose);
      await _open(container, 'video-a');
      host.commands.clear();

      await container.read(playerViewModelProvider('video-a').notifier).retry();

      expect(
        host.commands.map((command) => command.runtimeType).toList(),
        <Type>[StreamPlayerPrepare, StreamPlayerPlay],
      );
    });

    test('like and save are screen-local and do not reach the host', () async {
      final container = _container(_vodItem);
      addTearDown(container.dispose);
      await _open(container, 'video-a');
      host.commands.clear();

      final notifier = container.read(
        playerViewModelProvider('video-a').notifier,
      );
      notifier.toggleLiked();
      notifier.toggleSaved();

      final uiState = container
          .read(playerViewModelProvider('video-a'))
          .requireValue;
      expect(uiState.isLiked, isTrue);
      expect(uiState.isSaved, isTrue);
      expect(host.commands, isEmpty);
    });
  });

  group('teardown', () {
    test('leaving the player releases the native player', () async {
      final container = _container(_vodItem);
      await _open(container, 'video-a');

      container.dispose();
      await pumpEventQueue();

      // Not optional. A leaked player holds a hardware decoder, and on most TVs the third or fourth
      // leaked decoder is where playback stops being able to start at all.
      expect(host.disposed, <int>[1]);
    });
  });
}

/// Builds a container with the catalogue replaced, so no dummy data or network is involved.
ProviderContainer _container(PlaybackRepository repository) =>
    ProviderContainer.test(
      overrides: [playbackRepositoryProvider.overrideWithValue(repository)],
    );

/// Opens [itemId] and keeps the provider alive for the length of the test.
///
/// The subscription is what stops auto-dispose from tearing the player down between the `await` and
/// the assertions.
Future<PlayerUiState> _open(ProviderContainer container, String itemId) async {
  final subscription = container.listen(
    playerViewModelProvider(itemId),
    (_, _) {},
  );
  addTearDown(subscription.close);
  final uiState = await container.read(playerViewModelProvider(itemId).future);
  // `loadAndPlay` is deliberately not awaited inside `build`, so let its commands land.
  await pumpEventQueue();
  return uiState;
}

final _vodItem = _FakePlaybackRepository(
  PlaybackItem(
    id: 'video-a',
    title: 'Video A',
    description: 'An on-demand item',
    streamUrl: Uri.parse('https://cdn.example/a.m3u8'),
    isLive: false,
  ),
);

final _liveItem = _FakePlaybackRepository(
  PlaybackItem(
    id: 'channel-a',
    title: 'Channel A',
    description: 'A live channel',
    streamUrl: Uri.parse('https://cdn.example/live.m3u8'),
    isLive: true,
  ),
);

final _failingRepository = _FakePlaybackRepository(null);

final class _FakePlaybackRepository implements PlaybackRepository {
  const _FakePlaybackRepository(this._item);

  final PlaybackItem? _item;

  @override
  Future<PlaybackItem> getPlaybackItem(String itemId) async {
    final item = _item;
    if (item == null) {
      throw StateError('No catalogue item with id "$itemId"');
    }
    return item;
  }
}

/// A host that records commands and lets a test push facts.
final class _FakeStreamPlayerHost extends StreamPlayerPlatform {
  final List<StreamPlayerConfig> createdPlayers = <StreamPlayerConfig>[];
  final List<StreamPlayerCommand> commands = <StreamPlayerCommand>[];
  final List<int> disposed = <int>[];

  final StreamController<StreamPlayerEvent> _events =
      StreamController<StreamPlayerEvent>.broadcast();

  void emit(StreamPlayerEvent event) => _events.add(event);

  @override
  StreamPlayerCapabilities get capabilities => StreamPlayerCapabilities.full;

  @override
  Future<void> initialize() async {}

  @override
  Future<int> create(StreamPlayerConfig config) async {
    createdPlayers.add(config);
    return createdPlayers.length;
  }

  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
  }

  @override
  Stream<StreamPlayerEvent> events(int playerId) => _events.stream;

  @override
  Future<void> dispatch(int playerId, StreamPlayerCommand command) async {
    commands.add(command);
  }

  @override
  Future<Duration> position(int playerId) async => Duration.zero;

  @override
  Future<bool> isPreparedFor(int playerId, Uri uri) async => false;

  @override
  Widget buildView(int playerId, StreamPlayerViewOptions options) =>
      ColoredBox(color: options.shutterColor);
}
