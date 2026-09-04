import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/view/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders loading state', (tester) async {
    await tester.pumpWidget(_app(state: const .loading()));

    expect(find.text('Loading your StreamTV home...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders content state', (tester) async {
    await tester.pumpWidget(_app(state: const .data(_sections)));
    await tester.pump();

    expect(find.text('Opening Night'), findsOneWidget);
  });

  testWidgets('retries from error state', (tester) async {
    var retryCount = 0;
    await tester.pumpWidget(
      _app(
        state: AsyncValue.error(
          StateError('Network unavailable'),
          StackTrace.empty,
        ),
        onRetry: () => retryCount += 1,
      ),
    );

    await tester.tap(find.text('Try again'));
    expect(retryCount, 1);
  });

  testWidgets('moves focus right and activates the next TV card', (
    tester,
  ) async {
    HomeItem? selectedItem;
    await tester.pumpWidget(
      _app(
        state: const .data(_focusSections),
        onItemPressed: (item) => selectedItem = item,
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(selectedItem?.id, 'second');
  });
}

Widget _app({
  required AsyncValue<List<HomeSection>> state,
  VoidCallback? onRetry,
  ValueChanged<HomeItem>? onItemPressed,
}) {
  return MaterialApp(
    theme: StreamTvTheme.dark,
    home: HomeLceView(
      state: state,
      onRetry: onRetry ?? () {},
      onItemPressed: onItemPressed ?? (_) {},
      autoPlayBanners: false,
    ),
  );
}

const _sections = [
  HomeSection(
    id: 'featured',
    title: 'Featured today',
    viewType: .banner,
    items: [
      HomeItem(
        id: 'opening-night',
        title: 'Opening Night',
        description: 'Live coverage',
        kind: .video,
      ),
    ],
  ),
];

const _focusSections = [
  HomeSection(
    id: 'focus-row',
    title: 'Focus row',
    viewType: .videos,
    items: [
      HomeItem(
        id: 'first',
        title: 'First',
        description: 'First item',
        kind: .video,
      ),
      HomeItem(
        id: 'second',
        title: 'Second',
        description: 'Second item',
        kind: .series,
      ),
    ],
  ),
];
