import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/widgets/list_content_view/list_content_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builder creates items lazily and activates selection', (
    tester,
  ) async {
    final focusNode = FocusNode(debugLabel: 'test-list-content');
    addTearDown(focusNode.dispose);
    var selectedIndex = -1;

    await tester.pumpWidget(
      _app(
        child: ListContentView.builder(
          itemCount: 6,
          focusNode: focusNode,
          autofocus: true,
          itemWidth: 180,
          itemHeight: 100,
          onSelectedItemPressed: (index) => selectedIndex = index,
          itemBuilder: _buildItem,
        ),
      ),
    );
    await tester.pump();

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.childrenDelegate, isA<SliverChildBuilderDelegate>());
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(selectedIndex, 1);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('separated loops six items but keeps one focus node', (
    tester,
  ) async {
    final focusNode = FocusNode(debugLabel: 'looping-list-content');
    addTearDown(focusNode.dispose);
    var selectedIndex = -1;

    await tester.pumpWidget(
      _app(
        child: ListContentView.separated(
          itemCount: 6,
          focusNode: focusNode,
          autofocus: true,
          itemWidth: 180,
          itemHeight: 100,
          separatorExtent: 12,
          separatorBuilder: (_, _) => const SizedBox.shrink(),
          onSelectedItemPressed: (index) => selectedIndex = index,
          itemBuilder: _buildItem,
        ),
      ),
    );
    await tester.pump();

    for (var index = 0; index < 6; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(selectedIndex, 0);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('five-item list stops at the final item', (tester) async {
    final focusNode = FocusNode(debugLabel: 'finite-list-content');
    addTearDown(focusNode.dispose);
    var selectedIndex = -1;

    await tester.pumpWidget(
      _app(
        child: ListContentView.builder(
          itemCount: 5,
          focusNode: focusNode,
          autofocus: true,
          itemWidth: 180,
          itemHeight: 100,
          onSelectedItemPressed: (index) => selectedIndex = index,
          itemBuilder: _buildItem,
        ),
      ),
    );
    await tester.pump();

    for (var index = 0; index < 6; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(selectedIndex, 4);
  });
}

Widget _buildItem(BuildContext context, int index, bool isSelected) {
  return ColoredBox(
    color: isSelected ? Colors.purple : Colors.grey,
    child: Center(child: Text('${index + 1}')),
  );
}

Widget _app({required Widget child}) {
  return MaterialApp(home: Scaffold(body: child));
}
