// Copyright 2022 Samsung Electronics Co., Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "video_player_tizen_plugin.h"

// video_player_avplay ships PlusPlayer binaries only for ARM Samsung TVs. Registering an empty
// plugin on emulator architectures lets the application launch for non-playback development. Any
// playback call receives Flutter's normal channel error, which the StreamTV adapter exposes through
// its existing StreamPlayerError state.
void VideoPlayerTizenPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  (void)registrar;
}
