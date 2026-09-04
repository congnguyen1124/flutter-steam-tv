#!/usr/bin/env python3
"""Convert Android VectorDrawable XML files to standalone SVG assets."""

from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ANDROID_NS = "http://schemas.android.com/apk/res/android"
SVG_NS = "http://www.w3.org/2000/svg"
ANDROID = f"{{{ANDROID_NS}}}"
SVG = f"{{{SVG_NS}}}"

ET.register_namespace("", SVG_NS)


class ConversionError(ValueError):
    """Raised when a VectorDrawable uses an unsupported construct."""


def android_attr(node: ET.Element, name: str, default: str | None = None) -> str | None:
    return node.get(f"{ANDROID}{name}", default)


def local_name(tag: str) -> str:
    return tag.rsplit("}", maxsplit=1)[-1]


def number(value: str | None, default: float = 0.0) -> float:
    return float(value) if value is not None else default


def svg_length(value: str | None, fallback: str) -> str:
    if value is None:
        return fallback
    match = re.fullmatch(r"([+-]?(?:\d+(?:\.\d*)?|\.\d+))(?:dp|dip|sp|px)?", value)
    if match is None:
        raise ConversionError(f"Unsupported dimension: {value}")
    return match.group(1)


def format_number(value: float) -> str:
    return f"{value:.6f}".rstrip("0").rstrip(".") or "0"


def color_and_alpha(value: str) -> tuple[str, float]:
    if value.startswith(("@", "?")):
        raise ConversionError(f"Resource/theme colors are unsupported: {value}")
    if re.fullmatch(r"#[0-9a-fA-F]{8}", value):
        return f"#{value[3:]}", int(value[1:3], 16) / 255
    if re.fullmatch(r"#[0-9a-fA-F]{4}", value):
        return f"#{value[2:]}", int(value[1] * 2, 16) / 255
    return value, 1.0


def add_paint(
    source: ET.Element,
    target: ET.Element,
    paint: str,
    alpha_name: str,
) -> None:
    value = android_attr(source, f"{paint}Color")
    if value is None:
        target.set(paint, "none")
        return
    color, color_alpha = color_and_alpha(value)
    explicit_alpha = number(android_attr(source, alpha_name), 1.0)
    target.set(paint, color)
    combined_alpha = color_alpha * explicit_alpha
    if combined_alpha < 1:
        target.set(f"{paint}-opacity", format_number(combined_alpha))


def convert_path(source: ET.Element) -> ET.Element:
    path_data = android_attr(source, "pathData")
    if not path_data:
        raise ConversionError("A <path> is missing android:pathData")

    target = ET.Element(f"{SVG}path", {"d": path_data})
    add_paint(source, target, "fill", "fillAlpha")
    add_paint(source, target, "stroke", "strokeAlpha")

    mappings = {
        "strokeWidth": "stroke-width",
        "strokeLineCap": "stroke-linecap",
        "strokeLineJoin": "stroke-linejoin",
        "strokeMiterLimit": "stroke-miterlimit",
    }
    for android_name, svg_name in mappings.items():
        if value := android_attr(source, android_name):
            target.set(svg_name, value)

    if fill_type := android_attr(source, "fillType"):
        target.set("fill-rule", "evenodd" if fill_type == "evenOdd" else "nonzero")
    if alpha := android_attr(source, "alpha"):
        target.set("opacity", alpha)

    unsupported = [
        name
        for name in ("trimPathStart", "trimPathEnd", "trimPathOffset")
        if android_attr(source, name) is not None
    ]
    if unsupported:
        raise ConversionError(f"Unsupported path attributes: {', '.join(unsupported)}")
    return target


def group_transform(source: ET.Element) -> str | None:
    rotation = number(android_attr(source, "rotation"))
    pivot_x = number(android_attr(source, "pivotX"))
    pivot_y = number(android_attr(source, "pivotY"))
    scale_x = number(android_attr(source, "scaleX"), 1.0)
    scale_y = number(android_attr(source, "scaleY"), 1.0)
    translate_x = number(android_attr(source, "translateX"))
    translate_y = number(android_attr(source, "translateY"))

    transforms: list[str] = []
    if translate_x or translate_y or pivot_x or pivot_y:
        transforms.append(
            f"translate({format_number(translate_x + pivot_x)} "
            f"{format_number(translate_y + pivot_y)})"
        )
    if rotation:
        transforms.append(f"rotate({format_number(rotation)})")
    if scale_x != 1 or scale_y != 1:
        transforms.append(
            f"scale({format_number(scale_x)} {format_number(scale_y)})"
        )
    if pivot_x or pivot_y:
        transforms.append(
            f"translate({format_number(-pivot_x)} {format_number(-pivot_y)})"
        )
    return " ".join(transforms) or None


def convert_children(source: ET.Element, target: ET.Element) -> None:
    for child in source:
        tag = local_name(child.tag)
        if tag == "path":
            target.append(convert_path(child))
        elif tag == "group":
            group = ET.SubElement(target, f"{SVG}g")
            if transform := group_transform(child):
                group.set("transform", transform)
            convert_children(child, group)
        elif tag == "clip-path":
            raise ConversionError("<clip-path> is not supported yet")
        else:
            raise ConversionError(f"Unsupported VectorDrawable tag: <{tag}>")


def convert_file(source_path: Path, target_path: Path, overwrite: bool) -> None:
    if target_path.exists() and not overwrite:
        raise ConversionError(f"Target exists (use --overwrite): {target_path}")

    source = ET.parse(source_path).getroot()
    if local_name(source.tag) != "vector":
        raise ConversionError("Root element must be <vector>")

    viewport_width = android_attr(source, "viewportWidth")
    viewport_height = android_attr(source, "viewportHeight")
    if viewport_width is None or viewport_height is None:
        raise ConversionError("VectorDrawable must define viewportWidth/viewportHeight")

    target = ET.Element(
        f"{SVG}svg",
        {
            "width": svg_length(android_attr(source, "width"), viewport_width),
            "height": svg_length(android_attr(source, "height"), viewport_height),
            "viewBox": f"0 0 {viewport_width} {viewport_height}",
        },
    )
    if alpha := android_attr(source, "alpha"):
        target.set("opacity", alpha)
    convert_children(source, target)

    target_path.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(target, space="  ")
    ET.ElementTree(target).write(target_path, encoding="utf-8", xml_declaration=True)


def source_files(source: Path) -> list[Path]:
    if source.is_file():
        return [source]
    if source.is_dir():
        return sorted(source.glob("*.xml"))
    raise ConversionError(f"Source does not exist: {source}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="VectorDrawable XML file or directory")
    parser.add_argument("output", type=Path, help="Output SVG file or directory")
    parser.add_argument("--overwrite", action="store_true", help="Replace existing SVG files")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        files = source_files(args.source)
    except ConversionError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    if not files:
        print("error: no XML files found", file=sys.stderr)
        return 1

    failures = 0
    for source in files:
        target = args.output if len(files) == 1 and args.output.suffix else args.output / f"{source.stem}.svg"
        try:
            convert_file(source, target, args.overwrite)
            print(f"converted: {source} -> {target}")
        except (ConversionError, ET.ParseError, OSError) as error:
            failures += 1
            print(f"error: {source}: {error}", file=sys.stderr)

    print(f"summary: {len(files) - failures} converted, {failures} failed")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
