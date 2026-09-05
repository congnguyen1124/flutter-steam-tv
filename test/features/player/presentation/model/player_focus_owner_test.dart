import 'package:flutter_steam_tv/features/player/presentation/model/player_focus_owner.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section_stack.dart';
import 'package:flutter_test/flutter_test.dart';

/// The precedence order is the whole point of having one focus owner instead of several booleans,
/// so it is what gets pinned. Pure, so no widget tree is involved.
void main() {
  final settled = PlayerSectionStack.empty
      .open(PlayerSection.settings)
      .onEnterFinished();

  group('precedence', () {
    test('an error outranks everything', () {
      final owner = resolvePlayerFocusOwner(
        hasError: true,
        sections: settled,
        isControllerVisible: true,
      );

      expect(owner, PlayerFocusOwner.error);
    });

    test('a transition outranks the section it animates', () {
      final entering = PlayerSectionStack.empty.open(PlayerSection.settings);

      final owner = resolvePlayerFocusOwner(
        hasError: false,
        sections: entering,
        isControllerVisible: true,
      );

      // Parked, not section: the panel exists but cannot hold focus until it settles.
      expect(owner, PlayerFocusOwner.parked);
    });

    test('a settled section outranks the chrome beneath it', () {
      final owner = resolvePlayerFocusOwner(
        hasError: false,
        sections: settled,
        isControllerVisible: true,
      );

      // Both being true at once is exactly the state the boolean version got wrong: two subtrees
      // each believing focus was theirs, and whichever effect ran last won.
      expect(owner, PlayerFocusOwner.section);
    });

    test('the chrome outranks the bare surface', () {
      final owner = resolvePlayerFocusOwner(
        hasError: false,
        sections: PlayerSectionStack.empty,
        isControllerVisible: true,
      );

      expect(owner, PlayerFocusOwner.controller);
    });

    test('the surface owns focus when nothing else does', () {
      final owner = resolvePlayerFocusOwner(
        hasError: false,
        sections: PlayerSectionStack.empty,
      );

      expect(owner, PlayerFocusOwner.surface);
    });
  });

  group('exit asymmetry', () {
    test('exiting onto a parent panel parks focus', () {
      final exiting = settled
          .open(PlayerSection.quality)
          .onEnterFinished()
          .dismissCurrent();

      final owner = resolvePlayerFocusOwner(hasError: false, sections: exiting);

      // The parent cannot take focus until the animation frees it, so focus has to wait somewhere.
      expect(owner, PlayerFocusOwner.parked);
    });

    test('exiting to the base level hands focus straight back', () {
      final exiting = settled.dismissCurrent();

      final owner = resolvePlayerFocusOwner(
        hasError: false,
        sections: exiting,
        isControllerVisible: true,
      );

      // There is a settled destination already on screen, so parking would be a pointless hop.
      expect(owner, PlayerFocusOwner.controller);
    });

    test('exiting to a base level with no chrome lands on the surface', () {
      // The portrait player, which has no transient chrome.
      final exiting = settled.dismissCurrent();

      final owner = resolvePlayerFocusOwner(hasError: false, sections: exiting);

      expect(owner, PlayerFocusOwner.surface);
    });
  });
}
