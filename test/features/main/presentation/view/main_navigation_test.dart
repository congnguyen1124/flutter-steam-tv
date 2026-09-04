import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/app/stream_tv_app.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_colors.dart';
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
  });
}

void _configureTvView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 720);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
