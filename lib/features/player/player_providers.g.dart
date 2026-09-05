// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The feature's composition root: the one place a data implementation meets a domain interface.
///
/// `keepAlive`, because resolving a catalogue id should not repeat every time the player screen
/// rebuilds, and this holds no per-screen state.
///
/// It reads Home's repository rather than a catalogue of its own — see
/// [HomeCatalogPlaybackRepository] for why, and for what replaces it when a real API arrives.

@ProviderFor(playbackRepository)
final playbackRepositoryProvider = PlaybackRepositoryProvider._();

/// The feature's composition root: the one place a data implementation meets a domain interface.
///
/// `keepAlive`, because resolving a catalogue id should not repeat every time the player screen
/// rebuilds, and this holds no per-screen state.
///
/// It reads Home's repository rather than a catalogue of its own — see
/// [HomeCatalogPlaybackRepository] for why, and for what replaces it when a real API arrives.

final class PlaybackRepositoryProvider
    extends
        $FunctionalProvider<
          PlaybackRepository,
          PlaybackRepository,
          PlaybackRepository
        >
    with $Provider<PlaybackRepository> {
  /// The feature's composition root: the one place a data implementation meets a domain interface.
  ///
  /// `keepAlive`, because resolving a catalogue id should not repeat every time the player screen
  /// rebuilds, and this holds no per-screen state.
  ///
  /// It reads Home's repository rather than a catalogue of its own — see
  /// [HomeCatalogPlaybackRepository] for why, and for what replaces it when a real API arrives.
  PlaybackRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlaybackRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaybackRepository create(Ref ref) {
    return playbackRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackRepository>(value),
    );
  }
}

String _$playbackRepositoryHash() =>
    r'b8a49906a30dd0e313076c87a5387097adc6520c';
