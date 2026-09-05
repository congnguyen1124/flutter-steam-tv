import 'package:stream_player/stream_player.dart';

/// One selectable option in the settings panel.
final class PlayerSettingOption {
  /// Describes one option.
  const PlayerSettingOption({
    required this.id,
    required this.label,
    required this.isSelected,
  });

  /// The id to pass back to the player.
  final String id;

  /// What the viewer reads.
  final String label;

  /// Whether this is the option in effect.
  final bool isSelected;
}

/// One category in the settings panel.
final class PlayerSettingCategory {
  /// Describes one category and its options.
  const PlayerSettingCategory({required this.kind, required this.options});

  /// Which setting this is.
  final PlayerSettingKind kind;

  /// The options, in the order they are shown.
  final List<PlayerSettingOption> options;
}

/// The settings a player can offer.
enum PlayerSettingKind {
  /// Video rendition.
  quality,

  /// Audio rendition.
  audio,

  /// Subtitle rendition.
  subtitles,
}

/// What the settings panel renders.
///
/// ## Why this is derived and not stored
///
/// Renditions come and go as a manifest reloads, and the host is the only thing that knows what is
/// currently selectable. Deriving the panel from the live [StreamPlayerState] on every build means
/// it cannot show a rendition that has disappeared, and there is no second copy to keep in step.
final class PlayerSettingsUiState {
  /// Builds a panel state from the categories that have something to offer.
  const PlayerSettingsUiState({required this.categories});

  /// Derives the panel from what the host reports and what it says it supports.
  ///
  /// A category with fewer than two options is dropped: a menu with one entry is a label, and on a
  /// remote it costs the viewer three presses to learn it could not have been anything else.
  ///
  /// [capabilities] is checked first, so a host that reports no renditions because it cannot select
  /// them — Tizen — offers no settings button at all rather than an empty panel.
  factory PlayerSettingsUiState.from({
    required StreamPlayerState playerState,
    required StreamPlayerCapabilities capabilities,
  }) {
    final categories = <PlayerSettingCategory>[];

    if (capabilities.videoTrackSelection &&
        playerState.videoTracks.length > 1) {
      categories.add(
        PlayerSettingCategory(
          kind: .quality,
          options: [
            PlayerSettingOption(
              id: StreamPlayerVideoTrack.autoId,
              label: 'Auto',
              // Adaptive selection is in effect when nothing was pinned. Several renditions report
              // `isSelected` at once while it runs, so "exactly one is selected" is the signal that
              // the viewer chose a specific one.
              isSelected:
                  playerState.videoTracks.where((t) => t.isSelected).length !=
                  1,
            ),
            ..._qualityOptions(playerState.videoTracks),
          ],
        ),
      );
    }

    if (capabilities.audioTrackSelection &&
        playerState.audioTracks.length > 1) {
      categories.add(
        PlayerSettingCategory(
          kind: .audio,
          options: [
            for (final track in playerState.audioTracks)
              PlayerSettingOption(
                id: track.id,
                label: _trackLabel(
                  label: track.label,
                  language: track.language,
                ),
                isSelected: track.isSelected,
              ),
          ],
        ),
      );
    }

    if (capabilities.textTrackSelection && playerState.textTracks.isNotEmpty) {
      categories.add(
        PlayerSettingCategory(
          kind: .subtitles,
          options: [
            PlayerSettingOption(
              id: StreamPlayerTextTrack.offId,
              label: 'Off',
              isSelected: playerState.textTracks.every(
                (track) => !track.isSelected,
              ),
            ),
            for (final track in playerState.textTracks)
              PlayerSettingOption(
                id: track.id,
                label: _trackLabel(
                  label: track.label,
                  language: track.language,
                ),
                isSelected: track.isSelected,
              ),
          ],
        ),
      );
    }

    return PlayerSettingsUiState(categories: categories);
  }

  /// Nothing to offer.
  static const PlayerSettingsUiState empty = PlayerSettingsUiState(
    categories: <PlayerSettingCategory>[],
  );

  /// The categories with something to offer.
  final List<PlayerSettingCategory> categories;

  /// Whether a settings button should be shown at all.
  bool get isAvailable => categories.isNotEmpty;

  /// Highest rendition first, de-duplicated by height.
  ///
  /// The engine already drops unlabelable renditions and keeps the highest bitrate per height, so
  /// this only has to order them the way a viewer reads a quality menu — best at the top.
  static List<PlayerSettingOption> _qualityOptions(
    List<StreamPlayerVideoTrack> tracks,
  ) {
    final sorted = [...tracks]..sort((a, b) => b.height.compareTo(a.height));
    return [
      for (final track in sorted)
        PlayerSettingOption(
          id: track.id,
          label: '${track.height}p',
          isSelected:
              track.isSelected && sorted.where((t) => t.isSelected).length == 1,
        ),
    ];
  }

  /// The manifest's own name, its language tag, or a last-resort label.
  ///
  /// Never empty: an unlabelled row is unreachable on a remote, because there is nothing to read
  /// and nothing to aim at.
  static String _trackLabel({required String label, required String language}) {
    if (label.isNotEmpty) {
      return label;
    }
    if (language.isNotEmpty) {
      return language.toUpperCase();
    }
    return 'Default';
  }
}
