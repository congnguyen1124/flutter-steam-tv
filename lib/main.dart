import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/app/stream_tv_app.dart';
import 'package:flutter_steam_tv/core/player/stream_player_host.dart';

void main() {
  registerStreamPlayerHost();
  runApp(const ProviderScope(child: StreamTvApp()));
}
