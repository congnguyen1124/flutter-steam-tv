import 'package:flutter/material.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_item.dart';
import 'package:flutter_steam_tv/features/home/domain/model/home_section.dart';
import 'package:flutter_steam_tv/features/home/presentation/widget/home_section_row.dart';

final class HomeContentView extends StatelessWidget {
  const HomeContentView({
    required this.sections,
    required this.autofocusContent,
    required this.onItemPressed,
    super.key,
  });

  final List<HomeSection> sections;
  final bool autofocusContent;
  final ValueChanged<HomeItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(child: Text('No content is available yet'));
    }

    return ListView.separated(
      padding: const .only(bottom: 54),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 34),
      itemBuilder: (context, sectionIndex) {
        return HomeSectionRow(
          section: sections[sectionIndex],
          autofocusFirstItem: autofocusContent && sectionIndex == 0,
          onItemPressed: onItemPressed,
        );
      },
    );
  }
}
