import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_banner_info.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_vertical_banner_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The visible rectangles of the cards on screen, in left-to-right order.
  ///
  /// Read off the painted geometry rather than off the widgets, because the thing under test is
  /// where the scale ramp *leaves* each card — which a widget's own constraints do not tell you.
  List<Rect> cardRects(WidgetTester tester) {
    final finder = find.byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('home-vertical-banner-card-');
    });
    final rects = finder
        .evaluate()
        .map(
          (element) => tester.getRect(
            find.byElementPredicate((candidate) => candidate == element),
          ),
        )
        .toList(growable: false);
    return rects.toList(growable: false)
      ..sort((a, b) => a.left.compareTo(b.left));
  }

  Future<void> pumpSection(
    WidgetTester tester, {
    required FocusNode focusNode,
    ValueChanged<HomeItem>? onItemPressed,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

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
            onItemPressed: onItemPressed ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows shared info beside the portrait carousel', (tester) async {
    final focusNode = FocusNode(debugLabel: 'vertical-banner-test');
    addTearDown(focusNode.dispose);

    await pumpSection(tester, focusNode: focusNode);

    expect(find.byType(HomeBannerInfo), findsOneWidget);
    expect(find.text('Portrait 3'), findsOneWidget);

    final rects = cardRects(tester);
    expect(rects, isNotEmpty);
    expect(rects.map((rect) => rect.center.dy).toSet(), hasLength(1));
    expect(
      tester.getCenter(find.byType(HomeBannerInfo)).dx,
      lessThan(tester.getCenter(find.byType(HomeVerticalBannerSection)).dx),
    );
  });

  testWidgets('every neighbouring pair of cards sits the same distance apart', (
    tester,
  ) async {
    final focusNode = FocusNode(debugLabel: 'vertical-banner-test');
    addTearDown(focusNode.dispose);

    await pumpSection(tester, focusNode: focusNode);

    final rects = cardRects(tester);
    final gaps = [
      for (var index = 1; index < rects.length; index++)
        rects[index].left - rects[index - 1].right,
    ];

    // The regression this guards. A `PageView` gives every card the same slot, so a card scaled
    // down inside its slot leaves the remainder as empty space and the gap grows the further out a
    // pair sits — it measured about 13 at the centre and about 40 two steps out. Positions are now
    // derived from the gap instead of the other way round.
    expect(gaps, isNotEmpty);
    for (final gap in gaps) {
      expect(gap, closeTo(gaps.first, 0.5));
    }
  });

  testWidgets('cards shrink with distance from the centre', (tester) async {
    final focusNode = FocusNode(debugLabel: 'vertical-banner-test');
    addTearDown(focusNode.dispose);

    await pumpSection(tester, focusNode: focusNode);

    final rects = cardRects(tester);
    // Anchored on the widest card rather than on the section's midpoint: the carousel occupies a
    // right-hand column, so the section centre is nowhere near the centred card.
    var peak = 0;
    for (var index = 1; index < rects.length; index++) {
      if (rects[index].width > rects[peak].width) {
        peak = index;
      }
    }

    // Equal gaps must not have come at the cost of the scale ramp. Non-increasing rather than
    // strictly decreasing, because the ramp is measured over a clamped distance: everything from
    // two steps out shares the smallest scale.
    // The epsilon absorbs float noise between two cards that share a clamped scale.
    const epsilon = 0.01;
    for (var index = peak + 1; index < rects.length; index++) {
      expect(
        rects[index].width,
        lessThanOrEqualTo(rects[index - 1].width + epsilon),
      );
    }
    for (var index = peak - 1; index >= 0; index--) {
      expect(
        rects[index].width,
        lessThanOrEqualTo(rects[index + 1].width + epsilon),
      );
    }

    // The part of the ramp that actually has to move: an immediate neighbour is visibly smaller.
    expect(rects.length, greaterThan(2));
    expect(rects[peak + 1].width, lessThan(rects[peak].width));
    expect(rects[peak - 1].width, lessThan(rects[peak].width));
  });

  testWidgets('only the centred card is left unscrimmed', (tester) async {
    final focusNode = FocusNode(debugLabel: 'vertical-banner-test');
    addTearDown(focusNode.dispose);

    await pumpSection(tester, focusNode: focusNode);

    final scrims = tester
        .widgetList<ColoredBox>(find.byType(ColoredBox))
        .where((box) => box.color.a > 0 && box.color.a < 1)
        .map((box) => box.color.a)
        .toList(growable: false);

    // Uniform, not graduated: the strip should read as one dimmed row with a single lit item
    // rather than as a gradient of importance.
    expect(scrims, isNotEmpty);
    for (final alpha in scrims) {
      expect(alpha, closeTo(0.30, 0.001));
    }
  });

  testWidgets('right moves the selection and reports it', (tester) async {
    final focusNode = FocusNode(debugLabel: 'vertical-banner-test');
    addTearDown(focusNode.dispose);
    HomeItem? pressedItem;

    await pumpSection(
      tester,
      focusNode: focusNode,
      onItemPressed: (item) => pressedItem = item,
    );

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    expect(find.text('Portrait 4'), findsOneWidget);

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
