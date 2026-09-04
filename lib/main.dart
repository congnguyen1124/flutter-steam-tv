import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/app/stream_tv_app.dart';
import 'package:flutter_steam_tv/core/player/stream_player_host.dart';

void main() {
  // Before runApp, because the first StreamPlayerController.create() throws without a host, and a
  // viewer pressing play is not the moment to discover that.
  registerStreamPlayerHost();
  runApp(const ProviderScope(child: StreamTvApp()));
}
