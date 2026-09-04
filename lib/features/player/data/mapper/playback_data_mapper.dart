import 'package:flutter_steam_tv/features/player/data/model/playback_item_data.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';

/// Maps the transport model to the domain model.
extension PlaybackItemDataMapper on PlaybackItemData {
  /// Parses the URL here, at the data boundary.
  ///
  /// So the domain model holds a `Uri` that is known to be well formed, and a malformed manifest
  /// URL surfaces as an error on the player screen rather than as a `FormatException` thrown from
  /// inside a widget build.
  PlaybackItem toDomain() => PlaybackItem(
    id: id,
    title: title,
    description: description,
    streamUrl: Uri.parse(streamUrl),
    isLive: isLive,
  );
}
