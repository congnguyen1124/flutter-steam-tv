import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';

/// Turns a catalogue item into something the player can play.
extension HomeItemPlaybackMapper on HomeItem {
  /// The item to actually play when this one is pressed.
  ///
  /// A series usually has no stream of its own — pressing it means "start watching", which means
  /// episode one. Resolving that here rather than in the player means the player never has to know
  /// what a series is, and the state it publishes describes the episode that is really on screen.
  HomeItem get playableItem {
    if (hasStream) {
      return this;
    }
    for (final episode in episodes) {
      final playable = episode.playableItem;
      if (playable.hasStream) {
        return playable;
      }
    }
    return this;
  }

  /// Whether this item has anything to play at all.
  bool get hasStream => videoUrl.isNotEmpty || trailerUrl.isNotEmpty;

  /// Maps to the player's domain model.
  ///
  /// The URL is parsed here, at the boundary, so the player holds a `Uri` that is known to be well
  /// formed — a malformed manifest URL surfaces as an error on the player screen rather than as a
  /// `FormatException` thrown from inside a widget build.
  ///
  /// `trailerUrl` is a fallback, not a second feature: the catalogue fills it for every item, so an
  /// entry whose main stream is missing still plays *something* rather than showing a black
  /// screen. Never the other way round — a viewer who pressed play wants the film.
  PlaybackItem toPlaybackItem() => PlaybackItem(
    id: id,
    title: title,
    description: description,
    streamUrl: Uri.parse(videoUrl.isNotEmpty ? videoUrl : trailerUrl),
    // A channel is the catalogue's only live kind. Deriving it rather than storing a flag keeps one
    // source of truth: a row that renders as a channel and a stream that behaves like one cannot
    // disagree.
    isLive: kind == HomeItemKind.channel,
  );
}
