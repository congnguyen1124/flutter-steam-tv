import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/repository/home_repository.dart';
import 'package:flutter_steam_tv/features/player/data/mapper/home_item_playback_mapper.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/domain/repository/playback_repository.dart';

/// Resolves a playable item out of the Home catalogue.
///
/// ## Why the player reads Home's catalogue
///
/// Home items already carry `videoUrl`, `trailerUrl` and their kind, so the streams exist exactly
/// once, next to the rows that offer them. An earlier version of this file kept a second catalogue
/// inside the player keyed by the same ids — and the moment Home's ids changed, every press opened
/// a player that could not resolve its own item. Two lists of the same thing will always drift;
/// one will not.
///
/// The dependency points at [HomeRepository], the domain *interface*, so the player knows nothing
/// about DTOs, data sources, or where the catalogue is really stored.
///
/// ## When a real API arrives
///
/// This class is the seam. A `CatalogRepository` serving playback by id replaces it, and nothing
/// above [PlaybackRepository] changes — not the ViewModel, not the screen. The name says where the
/// data comes from today precisely so that swap is obvious.
final class HomeCatalogPlaybackRepository implements PlaybackRepository {
  /// Reads playable items out of [homeRepository].
  const HomeCatalogPlaybackRepository(this._homeRepository);

  final HomeRepository _homeRepository;

  @override
  Future<PlaybackItem> getPlaybackItem(String itemId) async {
    final sections = await _homeRepository.getHomeSections();

    for (final section in sections) {
      for (final item in section.items) {
        final match = _findById(item, itemId);
        if (match == null) {
          continue;
        }
        // Pressing a series resolves to its first episode, so what plays and what the title block
        // says are the same thing.
        final playable = match.playableItem;
        if (!playable.hasStream) {
          throw StateError('"$itemId" has no stream to play');
        }
        return playable.toPlaybackItem();
      }
    }

    // A `StateError` with the id in it, so the player screen shows its startup-error state and the
    // log names the item that could not be resolved.
    throw StateError('No catalogue item with id "$itemId"');
  }

  /// Depth-first, because episodes are catalogue items too.
  ///
  /// A viewer can reach an episode directly from a series row, and the id that travels is the
  /// episode's — so a search that only looked at top-level items would fail on exactly the items a
  /// series exists to offer.
  HomeItem? _findById(HomeItem item, String itemId) {
    if (item.id == itemId) {
      return item;
    }
    for (final episode in item.episodes) {
      final match = _findById(episode, itemId);
      if (match != null) {
        return match;
      }
    }
    return null;
  }
}
