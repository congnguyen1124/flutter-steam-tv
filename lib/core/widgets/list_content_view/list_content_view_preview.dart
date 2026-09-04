import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/core/widgets/list_content_view/list_content_view.dart';

@Preview(name: 'List content - separated', size: Size(1280, 220))
Widget listContentViewPreview() => const _ListContentViewPreview();

final class _ListContentViewPreview extends StatefulWidget {
  const _ListContentViewPreview();

  @override
  State<_ListContentViewPreview> createState() =>
      _ListContentViewPreviewState();
}

final class _ListContentViewPreviewState
    extends State<_ListContentViewPreview> {
  late final FocusNode _focusNode = FocusNode(
    debugLabel: 'preview-list-content',
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: StreamTvTheme.dark,
      home: Scaffold(
        body: Center(
          child: ListContentView.separated(
            itemCount: 6,
            focusNode: _focusNode,
            autofocus: true,
            itemWidth: 180,
            itemHeight: 112,
            separatorExtent: 14,
            separatorBuilder: (_, _) => const SizedBox.shrink(),
            onSelectedItemPressed: (_) {},
            itemBuilder: (context, index, isSelected) {
              return ColoredBox(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
                child: Center(child: Text('Item ${index + 1}')),
              );
            },
          ),
        ),
      ),
    );
  }
}
