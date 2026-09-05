import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/app/stream_tv_app.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
import 'package:flutter_steam_tv/features/main/presentation/view/main_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigates between top bar destinations', (tester) async {
    _configureTvView(tester);
    await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('steam-top-bar-item-search')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('search-screen')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('steam-top-bar-item-calendar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('calendar-screen')), findsOneWidget);
  });

  group('top-bar readability layer', () {
    // Read off MainScreen's own flag rather than off the painted gradient: the flag is the contract
    // between the destination and the shell, and a test that hunted for a DecoratedBox would pass
    // just as happily on a layer drawn at the wrong time.
    bool isLayerShown(WidgetTester tester) =>
        tester.widget<MainScreen>(find.byType(MainScreen))
            .showTopBarReadabilityLayer;

    testWidgets('is off over the hero, which carries its own scrim', (
      tester,
    ) async {
      _configureTvView(tester);
      await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
      await tester.pumpAndSettle();

      expect(isLayerShown(tester), isFalse);
    });

    testWidgets('turns on once focus leaves the first section', (tester) async {
      _configureTvView(tester);
      await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Without it the feed scrolls under the bar and the logo lands on a thumbnail.
      expect(isLayerShown(tester), isTrue);
    });

    testWidgets('is dropped on a destination that is inset below the bar', (
      tester,
    ) async {
      _configureTvView(tester);
      await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('steam-top-bar-item-search')));
      await tester.pumpAndSettle();

      // Home's request outlives Home. Search has nothing behind the bar, so honouring it would draw
      // a band of surface colour across the top of an already-inset screen.
      expect(isLayerShown(tester), isFalse);
    });
  });

  testWidgets('applies the lavender primary theme', (tester) async {
    _configureTvView(tester);
    await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
    await tester.pump();

    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).colorScheme.primary, StreamTvColors.primary);
  });

  testWidgets('moves across top bar destinations with the D-pad', (
    tester,
  ) async {
    _configureTvView(tester);
    await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('steam-top-bar-item-search')));
    await tester.pumpAndSettle();
    final shellState = tester.state(find.byType(MainScreen));

    final searchButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('steam-top-bar-item-search')),
        matching: find.byType(InkWell),
      ),
    );
    searchButton.focusNode!.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.text('Pulse of the court'), findsOneWidget);
    expect(tester.state(find.byType(MainScreen)), same(shellState));
    final homeButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('steam-top-bar-item-home')),
        matching: find.byType(InkWell),
      ),
    );
    expect(homeButton.focusNode!.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    final homeHero = tester.widget<Focus>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Focus &&
            widget.focusNode?.debugLabel == 'home-section:featured-stories',
      ),
    );
    expect(homeHero.focusNode!.hasFocus, isTrue);
  });

  testWidgets('down from top bar always enters the first content target', (
    tester,
  ) async {
    _configureTvView(tester);
    await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
    await tester.pumpAndSettle();

    final homeHero = tester.widget<Focus>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Focus &&
            widget.focusNode?.debugLabel == 'home-section:featured-stories',
      ),
    );
    expect(homeHero.focusNode!.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    final secondSection = tester.widget<Focus>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Focus &&
            widget.focusNode?.debugLabel == 'home-section:videos-for-you',
      ),
    );
    expect(secondSection.focusNode!.hasFocus, isTrue);

    for (var index = 0; index < 4; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }
    final verticalBanner = tester.widget<Focus>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Focus &&
            widget.focusNode?.debugLabel == 'home-section:portrait-discovery',
      ),
    );
    expect(verticalBanner.focusNode!.hasFocus, isTrue);

    final homeButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('steam-top-bar-item-home')),
        matching: find.byType(InkWell),
      ),
    );
    homeButton.focusNode!.requestFocus();
    await tester.pumpAndSettle();
    expect(homeButton.focusNode!.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(homeHero.focusNode!.hasFocus, isTrue);
  });
}

void _configureTvView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 720);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
