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

    expect(find.text('Featured today'), findsOneWidget);
    expect(tester.state(find.byType(MainScreen)), same(shellState));
    final homeButton = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('steam-top-bar-item-home')),
        matching: find.byType(InkWell),
      ),
    );
    expect(homeButton.focusNode!.hasFocus, isTrue);
  });

  testWidgets('returns from the top bar to the last focused content', (
    tester,
  ) async {
    _configureTvView(tester);
    await tester.pumpWidget(const ProviderScope(child: StreamTvApp()));
    await tester.pumpAndSettle();

    final firstCard = tester.widget<InkWell>(
      find.byWidgetPredicate(
        (widget) =>
            widget is InkWell &&
            widget.focusNode?.debugLabel == 'featured-today:opening-night',
      ),
    );
    expect(firstCard.focusNode!.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();

    final topBarButtons = tester.widgetList<InkWell>(
      find.descendant(
        of: find.byKey(const ValueKey('steam-top-bar')),
        matching: find.byType(InkWell),
      ),
    );
    expect(
      topBarButtons.any((button) => button.focusNode?.hasFocus ?? false),
      isTrue,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    expect(firstCard.focusNode!.hasFocus, isTrue);
  });
}

void _configureTvView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 720);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
