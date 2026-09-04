import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_steam_tv/core/widgets/tv_list_view/tv_list_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builder uses a lazy child delegate', (tester) async {
    await tester.pumpWidget(
      _app(
        child: TvListView.builder(
          itemCount: 20,
          itemBuilder: (_, index) =>
              SizedBox(height: 80, child: Text('Item $index')),
        ),
      ),
    );

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.childrenDelegate, isA<SliverChildBuilderDelegate>());
  });

  testWidgets('middle focus moves by exactly one row extent', (tester) async {
    final controller = ScrollController();
    final focusNodes = List.generate(
      6,
      (index) => FocusNode(debugLabel: 'tv-list-item-$index'),
    );
    addTearDown(controller.dispose);
    addTearDown(() {
      for (final node in focusNodes) {
        node.dispose();
      }
    });

    await tester.pumpWidget(
      _app(
        child: TvListView.separated(
          controller: controller,
          itemCount: focusNodes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 20),
          itemBuilder: (_, index) => SizedBox(
            height: 100,
            child: TextButton(
              focusNode: focusNodes[index],
              onPressed: () {},
              child: Text('Item $index'),
            ),
          ),
        ),
      ),
    );

    focusNodes[2].requestFocus();
    await tester.pumpAndSettle();
    final secondOffset = controller.offset;

    focusNodes[3].requestFocus();
    await tester.pumpAndSettle();
    final thirdOffset = controller.offset;

    expect(thirdOffset - secondOffset, closeTo(120, 0.1));
  });

  testWidgets('first and last focus align to list boundaries', (tester) async {
    final controller = ScrollController();
    final focusNodes = List.generate(
      6,
      (index) => FocusNode(debugLabel: 'boundary-item-$index'),
    );
    addTearDown(controller.dispose);
    addTearDown(() {
      for (final node in focusNodes) {
        node.dispose();
      }
    });

    await tester.pumpWidget(
      _app(
        child: TvListView.separated(
          controller: controller,
          itemCount: focusNodes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 20),
          itemBuilder: (_, index) => SizedBox(
            height: 100,
            child: TextButton(
              focusNode: focusNodes[index],
              onPressed: () {},
              child: Text('Item $index'),
            ),
          ),
        ),
      ),
    );

    for (final node in focusNodes) {
      node.requestFocus();
      await tester.pumpAndSettle();
    }
    expect(controller.offset, controller.position.maxScrollExtent);

    for (final node in focusNodes.reversed) {
      node.requestFocus();
      await tester.pumpAndSettle();
    }
    expect(controller.offset, 0);
  });

  testWidgets('entry focus always targets the first list item', (tester) async {
    final controller = ScrollController();
    final focusNodes = List.generate(
      6,
      (index) => FocusNode(debugLabel: 'entry-item-$index'),
    );
    addTearDown(controller.dispose);
    addTearDown(() {
      for (final node in focusNodes) {
        node.dispose();
      }
    });

    await tester.pumpWidget(
      _app(
        child: TvListView.separated(
          controller: controller,
          itemCount: focusNodes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 20),
          itemBuilder: (_, index) => SizedBox(
            height: 100,
            child: TextButton(
              focusNode: focusNodes[index],
              onPressed: () {},
              child: Text('Entry item $index'),
            ),
          ),
        ),
      ),
    );

    for (final node in focusNodes) {
      node.requestFocus();
      await tester.pumpAndSettle();
    }
    expect(controller.offset, controller.position.maxScrollExtent);

    final entryFocus = tester.widget<Focus>(
      find.byKey(const ValueKey('tv-list-view-entry-focus')),
    );
    entryFocus.focusNode!.requestFocus();
    await tester.pumpAndSettle();

    expect(focusNodes.first.hasFocus, isTrue);
    expect(controller.offset, 0);
  });

  testWidgets('vertical navigation throttles repeated moves', (tester) async {
    final focusNodes = List.generate(
      5,
      (index) => FocusNode(debugLabel: 'throttled-item-$index'),
    );
    addTearDown(() {
      for (final node in focusNodes) {
        node.dispose();
      }
    });

    await tester.pumpWidget(
      _app(
        child: TvListView.separated(
          itemCount: focusNodes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 20),
          itemBuilder: (_, index) => SizedBox(
            height: 100,
            child: TextButton(
              focusNode: focusNodes[index],
              onPressed: () {},
              child: Text('Throttled item $index'),
            ),
          ),
        ),
      ),
    );

    focusNodes.first.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focusNodes[1].hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focusNodes[1].hasFocus, isTrue);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(focusNodes[2].hasFocus, isTrue);
  });
}

Widget _app({required Widget child}) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(height: 300, child: child)),
  );
}
