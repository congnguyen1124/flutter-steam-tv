import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/core/widgets/list_content_view/list_content_view.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_content_card.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_section_row.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rank artwork keeps a small, consistent thumbnail overlap', () {
    for (final style in [
      HomeContentCardStyle.popularVideo,
      HomeContentCardStyle.popularShort,
    ]) {
      final metrics = HomeContentCardMetrics.fromItemWidth(
        style: style,
        itemWidth: 300,
      );

      expect(
        metrics.contentLeadingInset + metrics.rankOverlap,
        greaterThanOrEqualTo(metrics.rankArtworkHeight * 149 / 160),
      );
      expect(metrics.rankOverlap, lessThanOrEqualTo(16));
      expect(metrics.rankOverlap, lessThan(metrics.contentLeadingInset));
    }
  });

  testWidgets('normal landscape row exposes five and a half items', (
    tester,
  ) async {
    final list = await _pumpRow(tester, viewType: .videos, itemKind: .video);

    expect(list.itemWidth * 5.5 + list.separatorExtent * 5, closeTo(1232, 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ranked landscape row exposes four unclipped cells', (
    tester,
  ) async {
    final list = await _pumpRow(
      tester,
      viewType: .videosPopular,
      itemKind: .video,
    );

    expect(list.itemWidth * 4 + list.separatorExtent * 3, closeTo(1232, 0.1));
    expect(list.selectionLeadingInset, greaterThan(0));
    expect(list.selectionWidth, lessThan(list.itemWidth));
    expect(tester.takeException(), isNull);
  });

  testWidgets('short row uses a smaller six-and-a-half item layout', (
    tester,
  ) async {
    final list = await _pumpRow(tester, viewType: .shorts, itemKind: .short);

    expect(list.itemWidth * 6.5 + list.separatorExtent * 6, closeTo(1232, 0.1));
    expect(list.itemWidth, lessThan(200));
    expect(tester.takeException(), isNull);
  });
}

Future<ListContentView> _pumpRow(
  WidgetTester tester, {
  required HomeSectionViewType viewType,
  required HomeItemKind itemKind,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 720);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final focusNode = FocusNode(debugLabel: 'row-layout-test');
  addTearDown(focusNode.dispose);
  final items = List.generate(
    8,
    (index) => HomeItem(
      id: 'item-$index',
      title: 'Item $index',
      description:
          'A longer description for item $index that must fit on two lines.',
      kind: itemKind,
    ),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HomeSectionRow(
          section: HomeSection(
            id: 'layout-section',
            title: 'Layout section',
            viewType: viewType,
            items: items,
          ),
          focusNode: focusNode,
          initialSelectedIndex: 0,
          autofocus: false,
          onFocused: () {},
          onSelectedIndexChanged: (_) {},
          onItemPressed: (_) {},
        ),
      ),
    ),
  );
  await tester.pump();

  return tester.widget<ListContentView>(find.byType(ListContentView));
}
