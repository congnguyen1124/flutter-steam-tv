import 'package:flutter_steam_tv/features/home/home_providers.dart';
import 'package:flutter_steam_tv/features/player/data/repository/home_catalog_playback_repository.dart';
import 'package:flutter_steam_tv/features/player/domain/repository/playback_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_providers.g.dart';

/// The feature's composition root: the one place a data implementation meets a domain interface.
///
/// `keepAlive`, because resolving a catalogue id should not repeat every time the player screen
/// rebuilds, and this holds no per-screen state.
///
/// It reads Home's repository rather than a catalogue of its own — see
/// [HomeCatalogPlaybackRepository] for why, and for what replaces it when a real API arrives.
@Riverpod(keepAlive: true)
PlaybackRepository playbackRepository(Ref ref) =>
    HomeCatalogPlaybackRepository(ref.watch(homeRepositoryProvider));
