#!/usr/bin/env python3
"""Capture Flutter StreamTV screenshots and navigation GIFs from an Android TV device.

The showcase in `README.md` needs two kinds of evidence, and they cost very differently:

* A **still** is enough when the point is layout, hierarchy or colour.
* A **GIF** is the only honest way to show focus and navigation, because the thing being
  demonstrated is the *change* between frames.

Both are produced here rather than by hand so a capture can be re-run after a UI change and land in
the same file, instead of drifting into a folder of stale screenshots nobody can reproduce.

Android only. Every file it writes is suffixed `-android`, because the README pairs each shot with a
Tizen one captured by hand — see `updateReadme.md`. This tool drives `adb`; it will never produce
the Tizen column, and pretending otherwise would leave a gap nobody notices.

Usage
-----
    python3 tools/capture_media.py list
    python3 tools/capture_media.py shot home-overview
    python3 tools/capture_media.py gif topbar-focus
    python3 tools/capture_media.py all

Requirements: `adb` on PATH with exactly one device, and `ffmpeg` for GIF conversion.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

PACKAGE = "com.example.flutter_steam_tv"
ACTIVITY = f"{PACKAGE}/.MainActivity"
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "docs" / "images"

# Every file this tool writes carries this suffix, so the Tizen column of each README table can be
# filled with `<name>-tizen.<ext>` without renaming anything captured here.
PLATFORM_SUFFIX = "android"

# Wide enough to stay readable when GitHub scales it into a table cell, small enough that a handful
# of them do not dominate a clone.
GIF_WIDTH = 600
GIF_FPS = 10
GIF_COLORS = 96

# Stills are WebP: these are photographic screenshots, and lossless PNG costs roughly ten times as
# much for no visible gain at the size a README renders them.
STILL_QUALITY = 84


@dataclass(frozen=True)
class Capture:
    """One reproducible capture.

    `setup` runs before recording starts and is not shown; `steps` are the keys that make up the
    demonstration itself. Splitting them keeps a GIF focused on the interaction rather than on the
    navigation needed to reach it.
    """

    name: str
    description: str
    setup: list[str] = field(default_factory=list)
    steps: list[str] = field(default_factory=list)
    settle: float = 2.0
    setup_delay: float = 1.0
    step_delay: float = 1.0
    duration: int = 6

    # Per-capture GIF budget. A GIF over live video shares almost nothing between frames, so the
    # defaults that keep a mostly-static screen sharp produce a file several times too large for a
    # README when the whole frame is moving picture.
    gif_fps: int = GIF_FPS
    gif_colors: int = GIF_COLORS
    gif_width: int = GIF_WIDTH


def run(args: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(args, check=True, capture_output=True, **kwargs)


def adb(*args: str) -> subprocess.CompletedProcess:
    return run(["adb", *args])


def key(name: str) -> None:
    """Send one remote key. Accepts bare names like `DPAD_DOWN` or a `sleep:1.5` pause."""
    if name.startswith("sleep:"):
        time.sleep(float(name.split(":", 1)[1]))
        return
    adb("shell", "input", "keyevent", f"KEYCODE_{name}")


def relaunch() -> None:
    """Start every capture from a cold screen so one capture cannot inherit another's focus.

    Waiting for the window to actually take focus is not politeness — starting the activity while
    the previous task is still closing loses the race often enough to matter, and the symptom is a
    capture of the TV launcher that still succeeds and still writes a file.
    """
    adb("shell", "am", "force-stop", PACKAGE)
    time.sleep(2.0)
    adb("shell", "am", "start", "-n", ACTIVITY)
    await_foreground()


def await_foreground(timeout: float = 30.0) -> None:
    """Block until the app owns the focused window, or give up loudly."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        focus = run(["adb", "shell", "dumpsys", "window", "displays"]).stdout.decode()
        if PACKAGE in focus and "mCurrentFocus" in focus:
            for line in focus.splitlines():
                if "mCurrentFocus" in line and PACKAGE in line:
                    return
        time.sleep(0.5)
    sys.exit(f"{PACKAGE} never took window focus — is the app installed and the device awake?")


def apply_setup(capture: Capture) -> None:
    relaunch()
    time.sleep(capture.settle)
    for step in capture.setup:
        key(step)
        time.sleep(capture.setup_delay)


def output_path(capture: Capture, extension: str) -> Path:
    return OUTPUT_DIR / f"{capture.name}-{PLATFORM_SUFFIX}.{extension}"


def take_screenshot(capture: Capture) -> Path:
    apply_setup(capture)
    for step in capture.steps:
        key(step)
        time.sleep(capture.step_delay)
    time.sleep(0.6)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    raw = OUTPUT_DIR / f"{capture.name}.raw.png"
    with raw.open("wb") as output:
        subprocess.run(["adb", "exec-out", "screencap", "-p"], check=True, stdout=output)

    destination = output_path(capture, "webp")
    run(["ffmpeg", "-v", "error", "-y", "-i", str(raw),
         "-c:v", "libwebp", "-quality", str(STILL_QUALITY), "-compression_level", "6",
         str(destination)])
    raw.unlink(missing_ok=True)
    return destination


def take_gif(capture: Capture) -> Path:
    apply_setup(capture)

    device_mp4 = "/sdcard/flutter_streamtv_capture.mp4"
    recorder = subprocess.Popen(
        ["adb", "shell", "screenrecord", "--bit-rate", "6000000",
         "--time-limit", str(capture.duration), device_mp4],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    # screenrecord needs a moment before it is actually capturing; keys sent earlier are lost.
    time.sleep(1.5)

    for step in capture.steps:
        key(step)
        time.sleep(capture.step_delay)

    recorder.wait(timeout=capture.duration + 30)
    # The encoder finishes writing after the process exits; pulling too early truncates the file.
    time.sleep(1.5)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    local_mp4 = OUTPUT_DIR / f"{capture.name}.mp4"
    adb("pull", device_mp4, str(local_mp4))
    adb("shell", "rm", "-f", device_mp4)

    destination = output_path(capture, "gif")
    convert_to_gif(local_mp4, destination, capture)
    local_mp4.unlink(missing_ok=True)
    return destination


def convert_to_gif(source: Path, destination: Path, capture: Capture) -> None:
    """Two-pass palette conversion.

    A single-pass GIF of a dark UI bands badly in the gradients this app is built from, and the
    white focus fill is exactly where banding is most visible.
    """
    scale = f"fps={capture.gif_fps},scale={capture.gif_width}:-1:flags=lanczos"
    run(["ffmpeg", "-v", "error", "-y", "-i", str(source),
         "-vf", f"{scale},split[a][b];"
                f"[a]palettegen=max_colors={capture.gif_colors}:stats_mode=diff[p];"
                f"[b][p]paletteuse=dither=bayer:bayer_scale=4",
         "-loop", "0", str(destination)])


# Home is the launch destination, so its captures need no setup. Everything else is reached with the
# same key path a viewer would use, which keeps the captures honest about reachability.
#
# Section order from the top: Banner, Videos, Popular videos, Series, Channels, Vertical banner,
# Shorts, Popular shorts. Top bar, left to right: Search, Home, Calendar, Setting, Profile.
# The landscape controller hides itself five seconds after the last *activation*. Moving focus along
# the control row does not defer it — the Compose reference behaves the same way, and `spec/player.md`
# explicitly forbids re-arming the timer on focus changes. A naive "reveal, then press Right four
# times, then Select" therefore races the timer: once it loses, one press is spent re-revealing the
# chrome and every press after it lands one control early, on a screenshot that still looks plausible.
#
# So no player capture counts presses against a deadline. Setup walks to the *end* of the row, which
# is self-correcting — a swallowed press costs a step, and extra presses at the end are no-ops — then
# waits out the timer. The demonstration itself is then two presses long, because the chrome comes
# back on the control it was left on.
OPEN_LANDSCAPE = ["sleep:3", "DPAD_RIGHT", "DPAD_RIGHT", "DPAD_CENTER", "sleep:16"]

# Six is the overshoot: four moves span the row, and two more absorb presses lost to a re-reveal.
ROW_OVERSHOOT = 6

# Down is the reveal key throughout: nothing sits below the control row, so it is the only direction
# that cannot also move focus if the chrome happens to still be up.
def PARK_ON(direction: str) -> list[str]:
    """Reveal the chrome, walk to the `direction` end of the row, and let it hide again."""
    return ["DPAD_DOWN"] + [direction] * ROW_OVERSHOOT + ["sleep:7"]


RECALL = ["DPAD_DOWN"]


CAPTURES: dict[str, Capture] = {
    "home-overview": Capture(
        name="home-overview",
        description="Home with the hero banner focused",
        settle=8.0,
    ),
    "home-rows": Capture(
        name="home-rows",
        description="Ranked Popular videos rail",
        steps=["DPAD_DOWN", "DPAD_DOWN"],
        settle=8.0,
    ),
    "home-series": Capture(
        name="home-series",
        description="Documentary series rail",
        steps=["DPAD_DOWN"] * 3,
        settle=8.0,
    ),
    "home-channels": Capture(
        name="home-channels",
        description="Live channels rail",
        steps=["DPAD_DOWN"] * 4,
        settle=8.0,
    ),
    "home-vertical-banner": Capture(
        name="home-vertical-banner",
        description="Portrait carousel section",
        steps=["DPAD_DOWN"] * 5,
        settle=8.0,
    ),
    "home-shorts": Capture(
        name="home-shorts",
        description="Fresh shorts rail with portrait cards",
        steps=["DPAD_DOWN"] * 6,
        settle=8.0,
    ),
    "home-row-navigation": Capture(
        name="home-row-navigation",
        description="Moving down into a rail and along it",
        setup=["sleep:2"],
        steps=["DPAD_DOWN", "DPAD_RIGHT", "DPAD_RIGHT", "DPAD_DOWN", "DPAD_RIGHT", "DPAD_RIGHT"],
        settle=8.0,
        duration=9,
    ),
    "topbar-focus": Capture(
        name="topbar-focus",
        description="Top-bar item expanding to reveal its label",
        setup=["sleep:2"],
        steps=["DPAD_UP", "DPAD_LEFT", "DPAD_RIGHT", "DPAD_RIGHT", "DPAD_RIGHT"],
        settle=8.0,
        duration=9,
    ),
    "search": Capture(
        name="search",
        description="Search with the on-screen keyboard",
        steps=["DPAD_UP", "DPAD_LEFT", "DPAD_CENTER", "sleep:2", "DPAD_DOWN"],
        settle=8.0,
    ),
    "calendar": Capture(
        name="calendar",
        description="Calendar EPG grid",
        steps=["DPAD_UP", "DPAD_RIGHT", "DPAD_CENTER", "sleep:2", "DPAD_DOWN"],
        settle=8.0,
    ),
    "setting": Capture(
        name="setting",
        description="Two-pane Setting screen",
        steps=["DPAD_UP", "DPAD_RIGHT", "DPAD_RIGHT", "DPAD_CENTER", "sleep:2", "DPAD_DOWN"],
        settle=8.0,
    ),
    "profile": Capture(
        name="profile",
        description="Profile with QR sign-in",
        steps=["DPAD_UP"] + ["DPAD_RIGHT"] * 3 + ["DPAD_CENTER", "sleep:2", "DPAD_DOWN"],
        settle=8.0,
    ),
    # The banner's third item is the Big Buck Bunny stream, so every player demo shows the same
    # content and the two orientations can be compared directly.
    "player-surface": Capture(
        name="player-surface",
        description="Landscape player with no chrome",
        setup=OPEN_LANDSCAPE[:-1],
        steps=["sleep:16"],
        settle=8.0,
    ),
    "player-controller": Capture(
        name="player-controller",
        description="Controller revealed, focus on play/pause",
        setup=OPEN_LANDSCAPE,
        steps=["DPAD_CENTER", "sleep:2"],
        settle=8.0,
    ),
    "player-metadata-section": Capture(
        name="player-metadata-section",
        description="Metadata panel opened from the Description pill",
        # `PARK_ON` walks to the leading end of the row; `RECALL` brings the chrome back on it.
        setup=OPEN_LANDSCAPE + PARK_ON("DPAD_LEFT"),
        steps=RECALL + ["DPAD_CENTER", "sleep:2"],
        settle=8.0,
    ),
    "player-settings-section": Capture(
        name="player-settings-section",
        description="Settings list, one row per category",
        setup=OPEN_LANDSCAPE + PARK_ON("DPAD_RIGHT"),
        steps=RECALL + ["DPAD_CENTER", "sleep:2"],
        settle=8.0,
    ),
    "player-quality-section": Capture(
        name="player-quality-section",
        description="Quality panel stacked over the settings list",
        setup=OPEN_LANDSCAPE + PARK_ON("DPAD_RIGHT"),
        # The second Select opens Quality, the first row of the settings list. Once a section is
        # open the auto-hide timer is cancelled, so this press is not racing anything.
        steps=RECALL + ["DPAD_CENTER", "sleep:2", "DPAD_CENTER", "sleep:2"],
        settle=8.0,
    ),
    "player-focus-restore": Capture(
        name="player-focus-restore",
        description="Chrome returning on Settings, up to the seek bar, and back down",
        # Parking in setup is what makes this GIF the demonstration it claims to be: the chrome
        # comes back on the control the viewer last used, rather than on play/pause.
        setup=OPEN_LANDSCAPE + PARK_ON("DPAD_RIGHT"),
        steps=RECALL + ["DPAD_UP", "DPAD_DOWN"],
        settle=8.0,
        step_delay=1.2,
        # Three presses at 1.2s, after screenrecord's 1.5s lead-in. Ten seconds recorded four of
        # full-frame video after the demonstration had finished, at roughly 700KB per second.
        duration=7,
        gif_fps=7,
        gif_colors=64,
        # Narrower than the rest. This is the one GIF whose entire frame is moving video, so it pays
        # the full per-frame cost; at 600px it lands over 3MB, which is more than a README should
        # ask a reader to download to watch focus move between two controls.
        gif_width=480,
    ),
    "vertical-player": Capture(
        name="vertical-player",
        description="Portrait stage and interaction panel, focus border at full strength",
        setup=["sleep:3"] + ["DPAD_DOWN"] * 6 + ["DPAD_CENTER", "sleep:18"],
        # Two Selects, not none. The stage's focus border is bright for two seconds and then fades
        # to a faint outline, so by the time the stream has loaded the border has already settled
        # and a still taken here would not show that the stage is a focus target at all. A Select
        # restarts that cycle; the second one puts playback back where the first found it.
        steps=["DPAD_CENTER", "DPAD_CENTER"],
        settle=8.0,
    ),
    "vertical-player-metadata": Capture(
        name="vertical-player-metadata",
        description="Portrait panel drawn transparent over the ambient gradient",
        setup=["sleep:3"] + ["DPAD_DOWN"] * 6 + ["DPAD_CENTER", "sleep:18"],
        steps=["DPAD_RIGHT", "DPAD_UP", "DPAD_CENTER", "sleep:2"],
        settle=8.0,
    ),
    "vertical-player-panel": Capture(
        name="vertical-player-panel",
        description="Stage to the action row, and along it",
        setup=["sleep:3"] + ["DPAD_DOWN"] * 6 + ["DPAD_CENTER", "sleep:18"],
        steps=["DPAD_RIGHT", "DPAD_UP", "DPAD_DOWN", "DPAD_RIGHT", "DPAD_LEFT"],
        settle=8.0,
        step_delay=1.2,
        duration=10,
    ),
}

GIF_CAPTURES = {
    "topbar-focus",
    "home-row-navigation",
    "player-focus-restore",
    "vertical-player-panel",
}


def require_tools() -> None:
    missing = [tool for tool in ("adb", "ffmpeg") if shutil.which(tool) is None]
    if missing:
        sys.exit(f"Missing required tool(s): {', '.join(missing)}")

    devices = run(["adb", "devices"]).stdout.decode()
    attached = [line for line in devices.splitlines()[1:] if line.strip().endswith("device")]
    if len(attached) != 1:
        sys.exit(f"Expected exactly one attached device, found {len(attached)}")


def capture_one(name: str) -> None:
    capture = CAPTURES[name]
    kind = "gif" if name in GIF_CAPTURES else "shot"
    print(f"  {kind:4}  {name} — {capture.description}")
    path = take_gif(capture) if kind == "gif" else take_screenshot(capture)
    print(f"        -> {path.relative_to(OUTPUT_DIR.parent.parent)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["list", "shot", "gif", "all"])
    parser.add_argument("name", nargs="?")
    args = parser.parse_args()

    if args.command == "list":
        for name, capture in CAPTURES.items():
            kind = "gif" if name in GIF_CAPTURES else "shot"
            print(f"{kind:4}  {name:28}  {capture.description}")
        return

    require_tools()

    if args.command == "all":
        for name in CAPTURES:
            capture_one(name)
        return

    if not args.name:
        sys.exit("A capture name is required. Run `list` to see them.")
    if args.name not in CAPTURES:
        sys.exit(f"Unknown capture '{args.name}'. Run `list` to see them.")

    capture = CAPTURES[args.name]
    path = take_gif(capture) if args.command == "gif" else take_screenshot(capture)
    print(path)


if __name__ == "__main__":
    main()
