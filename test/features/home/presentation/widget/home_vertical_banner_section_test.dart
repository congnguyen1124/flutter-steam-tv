import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_banner_info.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_vertical_banner_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows shared info beside a centered portrait carousel', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final focusNode = FocusNode(debugLabel: 'vertical-banner-test');
    addTearDown(focusNode.dispose);
    HomeItem? pressedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeVerticalBannerSection(
            items: _items,
            focusNode: focusNode,
            initialSelectedIndex: 3,
            autofocus: false,
            autoPlay: false,
            onFocused: () {},
            onSelectedIndexChanged: (_) {},
            onItemPressed: (item) => pressedItem = item,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(HomeBannerInfo), findsOneWidget);
    expect(find.text('Portrait 3'), findsOneWidget);
    final pageViewFinder = find.byType(PageView);
    final pageView = tester.widget<PageView>(pageViewFinder);
    final carouselRect = tester.getRect(pageViewFinder);
    final cardFinder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('home-vertical-banner-card-');
    });
    final visibleCardCenters = cardFinder
        .evaluate()
        .map(
          (element) => tester.getCenter(
            find.byElementPredicate((value) => value == element),
          ),
        )
        .where(
          (center) =>
              center.dx >= carouselRect.left && center.dx <= carouselRect.right,
        )
        .toList(growable: false);

    expect(pageView.controller!.viewportFraction, 0.20);
    expect(pageView.clipBehavior, Clip.hardEdge);
    expect(visibleCardCenters, hasLength(5));
    expect(visibleCardCenters.map((center) => center.dy).toSet(), hasLength(1));
    expect(
      tester.getCenter(find.byType(HomeBannerInfo)).dx,
      lessThan(tester.getCenter(pageViewFinder).dx),
    );
    expect(
      tester
          .getRect(
            find.byKey(const ValueKey('home-vertical-banner-background')),
          )
          .left,
      greaterThan(tester.getRect(find.byType(HomeBannerInfo)).right),
    );

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    expect(find.text('Portrait 4'), findsOneWidget);
    final controller = tester.widget<PageView>(pageViewFinder).controller!;
    expect(controller.page! % _items.length, closeTo(4, 0.01));

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(pressedItem, same(_items[4]));
    expect(tester.takeException(), isNull);
  });
}

final List<HomeItem> _items = List.generate(
  8,
  (index) => HomeItem(
    id: 'portrait-$index',
    title: 'Portrait $index',
    description: 'Portrait description $index',
    kind: .short,
    ageRestriction: 'P',
  ),
  growable: false,
);
