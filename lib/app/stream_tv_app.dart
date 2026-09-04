import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/app/router/app_router.dart';
import 'package:flutter_steam_tv/core/design_system/stream_tv_theme.dart';

final class StreamTvApp extends ConsumerWidget {
  const StreamTvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'StreamTV',
      debugShowCheckedModeBanner: false,
      theme: StreamTvTheme.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
