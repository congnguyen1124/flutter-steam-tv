import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';

/// Resolves a catalogue id to something playable.
abstract interface class PlaybackRepository {
  /// Returns the playable item for [itemId].
  ///
  /// Throws [StateError] when the id is not in the catalogue, so the player screen renders its
  /// error state instead of a black surface with no explanation.
  Future<PlaybackItem> getPlaybackItem(String itemId);
}
