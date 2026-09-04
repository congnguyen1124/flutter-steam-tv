import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_steam_tv/app/stream_tv_app.dart';

void main() {
  runApp(const ProviderScope(child: StreamTvApp()));
}
