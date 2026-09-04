import 'package:flutter_steam_tv/features/player/data/mapper/playback_data_mapper.dart';
import 'package:flutter_steam_tv/features/player/data/source/playback_data_source.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/domain/repository/playback_repository.dart';

/// Reads the catalogue and maps it to the domain model.
final class PlaybackRepositoryImpl implements PlaybackRepository {
  /// Builds a repository over [dataSource].
  const PlaybackRepositoryImpl({required PlaybackDataSource dataSource})
    : _dataSource = dataSource;

  final PlaybackDataSource _dataSource;

  @override
  Future<PlaybackItem> getPlaybackItem(String itemId) async {
    final data = await _dataSource.fetchPlaybackItem(itemId);
    if (data == null) {
      // A `StateError` with the id in it, so the player screen shows its error state and the log
      // says which item could not be resolved.
      throw StateError('No playable stream for "$itemId"');
    }
    return data.toDomain();
  }
}
