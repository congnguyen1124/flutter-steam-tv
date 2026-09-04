import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_ui_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_player/stream_player.dart';

void main() {
  group('seekability', () {
    test('a live item is never seekable, even if a duration is reported', () {
      // A live manifest can briefly report a duration while its window is still being read. Trusting
      // it would put a seek bar on a live stream for a second and then take it away.
      final state = _state(
        isLive: true,
        playerState: StreamPlayerState.initial.copyWith(
          duration: const Duration(minutes: 5),
        ),
      );

      expect(state.isSeekable, isFalse);
      expect(state.progressFraction, 0);
    });

    test('an on-demand item with a duration is seekable', () {
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          duration: const Duration(seconds: 100),
          position: const Duration(seconds: 25),
          bufferedPosition: const Duration(seconds: 50),
        ),
      );

      expect(state.isSeekable, isTrue);
      expect(state.progressFraction, 0.25);
      expect(state.bufferedFraction, 0.5);
    });

    test('position is clamped to the duration', () {
      // A host can report a position a few milliseconds past the end as playback completes, and an
      // unclamped seek bar renders its thumb outside the track.
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          duration: const Duration(seconds: 100),
          position: const Duration(seconds: 101),
        ),
      );

      expect(state.position, const Duration(seconds: 100));
    });
  });

  group('errors', () {
    test('a non-retryable failure says so, so no retry is offered', () {
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          error: const StreamPlayerNotEntitledError(message: 'HTTP 403'),
        ),
      );

      expect(state.error, isNotNull);
      expect(state.error!.isRetryable, isFalse);
      expect(state.error!.message, isNotEmpty);
    });

    test('the host message never reaches the viewer', () {
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          error: const StreamPlayerUnknownError(message: 'ERROR_CODE_DECODING_FAILED'),
        ),
      );

      // The host owns the diagnosis; the app owns the copy. A decoder constant on screen is the
      // failure mode this split exists to prevent.
      expect(state.error!.message, isNot(contains('ERROR_CODE')));
    });
  });

  group('settings', () {
    test('a host without track selection offers no settings at all', () {
      final state = _state(
        capabilities: StreamPlayerCapabilities.basic,
        playerState: StreamPlayerState.initial.copyWith(
          videoTracks: _twoVideoTracks,
        ),
      );

      // Tizen reports no renditions because it cannot select them. Offering an empty panel would be
      // worse than offering nothing.
      expect(state.settings.isAvailable, isFalse);
    });

    test('a single rendition is not a menu', () {
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          videoTracks: [_twoVideoTracks.first],
        ),
      );

      expect(state.settings.isAvailable, isFalse);
    });

    test('quality options are highest first, with Auto on top', () {
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(videoTracks: _twoVideoTracks),
      );

      final quality = state.settings.categories.single;
      expect(quality.kind, PlayerSettingKind.quality);
      expect(
        quality.options.map((option) => option.label).toList(),
        <String>['Auto', '1080p', '720p'],
      );
    });

    test('Auto is selected while adaptive selection is running', () {
      // Several renditions report isSelected at once under adaptive selection, so "exactly one" is
      // the signal that the viewer pinned a quality.
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          videoTracks: [
            _twoVideoTracks.first,
            const StreamPlayerVideoTrack(
              id: '720',
              width: 1280,
              height: 720,
              bitrate: 3000000,
              isSelected: true,
            ),
          ],
        ),
      );

      final auto = state.settings.categories.single.options.first;
      expect(auto.label, 'Auto');
      expect(auto.isSelected, isTrue);
    });

    test('an unlabelled audio track falls back to its language, then to a default', () {
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          audioTracks: const [
            StreamPlayerAudioTrack(
              id: 'a',
              language: 'vi',
              label: '',
              isDefaultSelected: true,
              isSelected: true,
            ),
            StreamPlayerAudioTrack(
              id: 'b',
              language: '',
              label: '',
              isDefaultSelected: false,
              isSelected: false,
            ),
          ],
        ),
      );

      // An unlabelled row is unreachable on a remote: nothing to read, nothing to aim at.
      expect(
        state.settings.categories.single.options.map((option) => option.label).toList(),
        <String>['VI', 'Default'],
      );
    });

    test('subtitles always offer Off', () {
      final state = _state(
        playerState: StreamPlayerState.initial.copyWith(
          textTracks: const [
            StreamPlayerTextTrack(id: 'en', language: 'en', label: 'English', isSelected: false),
          ],
        ),
      );

      final subtitles = state.settings.categories.single;
      expect(subtitles.kind, PlayerSettingKind.subtitles);
      expect(subtitles.options.first.label, 'Off');
      expect(subtitles.options.first.isSelected, isTrue);
    });
  });

  group('formatPlayerClock', () {
    test('drops the hour under an hour', () {
      expect(formatPlayerClock(const Duration(minutes: 3, seconds: 7)), '3:07');
    });

    test('keeps the hour past an hour', () {
      expect(
        formatPlayerClock(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });

    test('a negative duration reads as zero', () {
      // Reachable while a live window is still being read, and "-1:-1" on screen reads as a bug.
      expect(formatPlayerClock(const Duration(seconds: -5)), '0:00');
    });
  });
}

const _twoVideoTracks = [
  StreamPlayerVideoTrack(
    id: '1080',
    width: 1920,
    height: 1080,
    bitrate: 6000000,
    isSelected: false,
  ),
  StreamPlayerVideoTrack(
    id: '720',
    width: 1280,
    height: 720,
    bitrate: 3000000,
    isSelected: false,
  ),
];

PlayerUiState _state({
  StreamPlayerState? playerState,
  StreamPlayerCapabilities capabilities = StreamPlayerCapabilities.full,
  bool isLive = false,
}) => PlayerUiState(
  item: PlaybackItem(
    id: 'wild-frontier',
    title: 'Wild Frontier',
    description: 'A journey into untouched landscapes',
    streamUrl: Uri.parse('https://example.invalid/a.m3u8'),
    isLive: isLive,
  ),
  playerState: playerState ?? StreamPlayerState.initial,
  capabilities: capabilities,
);
