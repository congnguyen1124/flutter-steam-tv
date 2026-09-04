import 'package:flutter_steam_tv/features/player/data/repository/playback_repository_impl.dart';
import 'package:flutter_steam_tv/features/player/data/source/playback_data_source.dart';
import 'package:flutter_steam_tv/features/player/domain/repository/playback_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_providers.g.dart';

/// The feature's composition root: the one place data implementations meet domain interfaces.
///
/// `keepAlive` on both, because a catalogue lookup should not be repeated every time the player
/// screen rebuilds, and neither holds per-screen state.

/// Where playable items come from.
@Riverpod(keepAlive: true)
PlaybackDataSource playbackDataSource(Ref ref) => const PlaybackDummyDataSource();

/// Resolves a catalogue id to something playable.
@Riverpod(keepAlive: true)
PlaybackRepository playbackRepository(Ref ref) =>
    PlaybackRepositoryImpl(dataSource: ref.watch(playbackDataSourceProvider));
