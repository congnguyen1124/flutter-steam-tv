import 'package:flutter_steam_tv/features/player/domain/model/playback_item.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_settings_ui_state.dart';
import 'package:stream_player/stream_player.dart';

/// Everything the player screen renders.
///
/// ## Why this wraps the player's own state instead of copying it
///
/// The screen needs three things the player cannot know — the item's title, whether it is live, and
/// copy for a failure — and everything else it needs is already in [StreamPlayerState], derived once
/// by the shared reducer. Holding a reference and deriving the rest keeps one source of truth: there
/// is no `isPlaying` here that could disagree with the player's.
///
/// [capabilities] rides along because most of the screen's structural decisions are capability
/// decisions: whether there is a settings button at all, whether a quality menu is worth opening.
final class PlayerUiState {
  /// Builds the screen's state.
  const PlayerUiState({
    required this.item,
    required this.playerState,
    required this.capabilities,
    this.isLiked = false,
    this.isSaved = false,
  });

  /// The item being played.
  final PlaybackItem item;

  /// The player's own snapshot.
  final StreamPlayerState playerState;

  /// What the host behind this player can do.
  final StreamPlayerCapabilities capabilities;

  /// Whether the viewer liked this item.
  ///
  /// Screen-local for now: there is no watchlist API yet, so this is the affordance without the
  /// persistence. It is here rather than in a widget's `State` so the control row stays a pure
  /// function of this value.
  final bool isLiked;

  /// Whether the viewer saved this item. Screen-local, as [isLiked].
  final bool isSaved;

  /// Whether frames are advancing.
  bool get isPlaying => playerState.isPlaying;

  /// Whether the spinner should be shown.
  bool get isBuffering => playerState.playbackState.isBuffering;

  /// Playback position, clamped so a seek bar cannot render past its own end.
  Duration get position =>
      playerState.position > duration && duration > Duration.zero ? duration : playerState.position;

  /// Length of the item, or zero for a live stream.
  Duration get duration => playerState.duration;

  /// How far the buffer reaches.
  Duration get bufferedPosition => playerState.bufferedPosition;

  /// Whether a seek bar makes sense at all.
  ///
  /// A live stream reports no duration, so a progress bar would sit permanently at zero and a seek
  /// would have nowhere to land. [PlaybackItem.isLive] is checked too, because a live manifest can
  /// briefly report a duration while its window is still being read.
  bool get isSeekable => !item.isLive && duration > Duration.zero;

  /// Playback progress in `0..1`, or zero while the duration is unknown.
  double get progressFraction => isSeekable ? playerState.progress : 0;

  /// Buffered progress in `0..1`, for the trailing portion of the seek bar.
  double get bufferedFraction {
    if (!isSeekable) {
      return 0;
    }
    final ratio = bufferedPosition.inMicroseconds / duration.inMicroseconds;
    return ratio.clamp(0.0, 1.0).toDouble();
  }

  /// What the settings panel can offer.
  PlayerSettingsUiState get settings => PlayerSettingsUiState.from(
    playerState: playerState,
    capabilities: capabilities,
  );

  /// The live failure as the screen needs it, or null when playback is healthy.
  PlayerErrorUiItem? get error {
    final error = playerState.error;
    if (error == null) {
      return null;
    }
    return PlayerErrorUiItem(message: _messageFor(error), isRetryable: error.isRetryable);
  }

  /// Returns a copy with the given fields replaced.
  PlayerUiState copyWith({
    StreamPlayerState? playerState,
    bool? isLiked,
    bool? isSaved,
  }) => PlayerUiState(
    item: item,
    playerState: playerState ?? this.playerState,
    capabilities: capabilities,
    isLiked: isLiked ?? this.isLiked,
    isSaved: isSaved ?? this.isSaved,
  );

  /// The app owns the copy; the player owns the diagnosis.
  ///
  /// That split is why the host classifies failures instead of formatting them — a library cannot
  /// know whether this screen says "You're offline" or something in Vietnamese, and it must not
  /// leak a decoder message to a viewer.
  String _messageFor(StreamPlayerError error) => switch (error) {
    StreamPlayerNoNetworkError() => 'No internet connection. Check your network and try again.',
    StreamPlayerNotFoundError() => 'This video is no longer available.',
    StreamPlayerNotEntitledError() => 'This video is not available on your account.',
    StreamPlayerUnsupportedFormatError() => 'This video cannot be played on this device.',
    StreamPlayerUnknownError() => 'Something went wrong while playing this video.',
  };
}

/// A playback failure as the UI needs it: one line of copy, and whether offering a retry is honest.
final class PlayerErrorUiItem {
  /// Describes a failure for the error panel.
  const PlayerErrorUiItem({required this.message, required this.isRetryable});

  /// What the viewer reads.
  final String message;

  /// Straight from the host's classification.
  ///
  /// Showing a retry button for a forbidden stream only invites the viewer to fail twice.
  final bool isRetryable;
}

/// `h:mm:ss`, or `m:ss` under an hour.
///
/// Free function rather than a method, because both the seek bar and the previews need it and
/// neither should have to hold a state object to format a number.
String formatPlayerClock(Duration duration) {
  final total = duration.isNegative ? Duration.zero : duration;
  final hours = total.inHours;
  final minutes = total.inMinutes.remainder(60);
  final seconds = total.inSeconds.remainder(60);
  final paddedSeconds = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$paddedSeconds';
  }
  return '$minutes:$paddedSeconds';
}
