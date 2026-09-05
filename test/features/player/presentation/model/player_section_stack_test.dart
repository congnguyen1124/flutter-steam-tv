import 'package:flutter_steam_tv/features/player/presentation/model/player_section.dart';
import 'package:flutter_steam_tv/features/player/presentation/model/player_section_stack.dart';
import 'package:flutter_test/flutter_test.dart';

/// The stack is a pure value with pure transitions, so every phase it can be in is assertable
/// without a widget tree, an animation, or a device.
void main() {
  group('opening', () {
    test('a fresh open is entering, not settled', () {
      final stack = PlayerSectionStack.empty.open(PlayerSection.settings);

      expect(stack.panelSection, PlayerSection.settings);
      expect(stack.isPanelEntering, isTrue);
      // The whole reason the phase exists: a panel sliding in must not take focus yet.
      expect(stack.isPanelSettled, isFalse);
      expect(stack.hasSectionInPlay, isTrue);
      expect(stack.isBaseLevel, isFalse);
    });

    test('it settles once its animation reports back', () {
      final stack = PlayerSectionStack.empty
          .open(PlayerSection.settings)
          .onEnterFinished();

      expect(stack.isPanelEntering, isFalse);
      expect(stack.isPanelSettled, isTrue);
    });

    test('a second open while one is entering is ignored', () {
      final stack = PlayerSectionStack.empty
          .open(PlayerSection.settings)
          .open(PlayerSection.metadata);

      // Two fast presses must not interleave two transitions and leave the stack describing a
      // screen that is not on it.
      expect(stack.stack, <PlayerSection>[PlayerSection.settings]);
    });

    test('a nested open keeps the parent composed underneath', () {
      final stack = PlayerSectionStack.empty
          .open(PlayerSection.settings)
          .onEnterFinished()
          .open(PlayerSection.quality);

      expect(stack.stack, <PlayerSection>[
        PlayerSection.settings,
        PlayerSection.quality,
      ]);
      // Both layers stay composed, which is what makes returning to Settings restore the row the
      // viewer was on instead of rebuilding the list.
      expect(stack.sectionLayers, <PlayerSection>[
        PlayerSection.settings,
        PlayerSection.quality,
      ]);
      expect(stack.panelSection, PlayerSection.quality);
    });
  });

  group('dismissing', () {
    test('the popped panel stays composed until its animation ends', () {
      final settled = PlayerSectionStack.empty
          .open(PlayerSection.settings)
          .onEnterFinished();

      final exiting = settled.dismissCurrent();

      expect(exiting.stack, isEmpty, reason: 'no longer navigable');
      expect(exiting.exitingSection, PlayerSection.settings);
      // Still composed, so it can slide out rather than vanish.
      expect(exiting.sectionLayers, <PlayerSection>[PlayerSection.settings]);
      expect(exiting.isPanelExiting, isTrue);
      expect(exiting.hasSectionInPlay, isTrue);

      final done = exiting.onExitFinished();

      expect(done.isBaseLevel, isTrue);
      expect(done.sectionLayers, isEmpty);
    });

    test('dismissing a child reveals its parent', () {
      final stack = PlayerSectionStack.empty
          .open(PlayerSection.settings)
          .onEnterFinished()
          .open(PlayerSection.quality)
          .onEnterFinished()
          .dismissCurrent();

      expect(stack.stack, <PlayerSection>[PlayerSection.settings]);
      expect(stack.exitingSection, PlayerSection.quality);
      expect(
        stack.panelSection,
        PlayerSection.quality,
        reason: 'still on top while it slides out',
      );

      final done = stack.onExitFinished();

      expect(done.panelSection, PlayerSection.settings);
      expect(done.isPanelSettled, isTrue);
    });

    test('a second dismiss while one is exiting is ignored', () {
      final stack = PlayerSectionStack.empty
          .open(PlayerSection.settings)
          .onEnterFinished()
          .open(PlayerSection.quality)
          .onEnterFinished()
          .dismissCurrent()
          .dismissCurrent();

      expect(stack.stack, <PlayerSection>[PlayerSection.settings]);
      expect(stack.exitingSection, PlayerSection.quality);
    });

    test('dismissing at the base level does nothing', () {
      expect(
        PlayerSectionStack.empty.dismissCurrent(),
        PlayerSectionStack.empty,
      );
    });
  });

  group('reset', () {
    test('clears everything with no animation', () {
      final stack = PlayerSectionStack.empty
          .open(PlayerSection.settings)
          .onEnterFinished()
          .open(PlayerSection.quality);

      // For when the screen underneath changed out from under the panels — a failure, or the
      // portrait player moving to another video. Animating a panel belonging to content that is
      // gone would be wrong.
      expect(stack.reset(), PlayerSectionStack.empty);
    });
  });

  group('section tree', () {
    test('setting categories are children of the settings list', () {
      expect(PlayerSection.quality.parent, PlayerSection.settings);
      expect(PlayerSection.audio.parent, PlayerSection.settings);
      expect(PlayerSection.subtitles.parent, PlayerSection.settings);
    });

    test('top-level sections have no parent', () {
      expect(PlayerSection.settings.parent, isNull);
      expect(PlayerSection.metadata.parent, isNull);
    });
  });
}
