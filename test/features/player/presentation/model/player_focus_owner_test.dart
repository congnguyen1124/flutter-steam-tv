import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_test/flutter_test.dart';

/// The precedence order is the whole point of having one focus owner instead of several booleans,
/// so it is what gets pinned. Pure, so no widget tree is involved.
void main() {
  group('resolvePlayerFocusOwner', () {
    test('an error outranks everything', () {
      final owner = resolvePlayerFocusOwner(
        hasError: true,
        isSettingsOpen: true,
        isControllerVisible: true,
      );

      expect(owner, PlayerFocusOwner.error);
    });

    test('an open panel outranks the controller underneath it', () {
      final owner = resolvePlayerFocusOwner(
        hasError: false,
        isSettingsOpen: true,
        isControllerVisible: true,
      );

      // Both being true at once is exactly the state the boolean version got wrong: two subtrees
      // each believing focus was theirs, and whichever effect ran last won.
      expect(owner, PlayerFocusOwner.settings);
    });

    test('the controller outranks the bare surface', () {
      final owner = resolvePlayerFocusOwner(
        hasError: false,
        isSettingsOpen: false,
        isControllerVisible: true,
      );

      expect(owner, PlayerFocusOwner.controller);
    });

    test('the surface owns focus when nothing else does', () {
      final owner = resolvePlayerFocusOwner(
        hasError: false,
        isSettingsOpen: false,
        isControllerVisible: false,
      );

      expect(owner, PlayerFocusOwner.surface);
    });
  });
}
