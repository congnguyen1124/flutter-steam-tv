import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';
import 'package:flutter_steam_tv/core/widgets/tv_list_view/tv_list_view.dart';

@Preview(name: 'TV list - focus anchored', size: Size(640, 480))
Widget tvListViewPreview() => const _TvListViewPreview();

final class _TvListViewPreview extends StatelessWidget {
  const _TvListViewPreview();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: StreamTvTheme.dark,
      home: Scaffold(
        body: TvListView.separated(
          itemCount: 8,
          padding: const .symmetric(vertical: 40),
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, index) {
            return Padding(
              padding: const .symmetric(horizontal: 48),
              child: FilledButton(
                autofocus: index == 0,
                onPressed: () {},
                child: Text('Section ${index + 1}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
