#!/usr/bin/env python3
"""
Synchronizes custom application themes with the active Matugen / Noctalia desktop palette.
Supported apps: FreeCAD, KiCad, Qucs-S, Arduino IDE, Calibre, Calibre-TUI, OrcaSlicer, OnlyOffice, GTK3/4.
"""
import os
import sys
import json
import uuid
import time
import subprocess

# 1. Resolve colors
def get_matugen_colors():
    # Try querying matugen directly from the wallpaper or noctalia starship palette
    starship_path = os.path.expanduser("~/.cache/noctalia/starship-palette.toml")
    wall_path = os.path.expanduser("~/Pictures/1-the-backwater.jpg")
    
    # Try matugen CLI
    try:
        cmd = ["matugen", "image", wall_path, "--source-color-index", "0", "--dry-run", "--json", "hex"]
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        raw = json.loads(res.stdout)["colors"]
        colors = {k: v["default"]["color"] for k, v in raw.items()}
        return colors
    except Exception as e:
        # Fallback to current known values
        return {
            "surface": "#17130b",
            "surface_container_lowest": "#110e07",
            "surface_container_low": "#1f1b13",
            "surface_container": "#241f17",
            "surface_container_high": "#2f2921",
            "surface_container_highest": "#39342b",
            "on_surface": "#ece1d4",
            "outline": "#9a8f80",
            "outline_variant": "#4e4639",
            "primary": "#ecc06c",
            "on_primary": "#412d00",
            "primary_container": "#5a4300",
            "secondary": "#d9c4a0",
            "tertiary": "#b2cfa7",
            "error": "#ffb4ab"
        }

colors = get_matugen_colors()
c_bg = colors.get("surface", "#17130b")
c_bg_low = colors.get("surface_container_low", "#1f1b13")
c_bg_card = colors.get("surface_container", "#241f17")
c_bg_high = colors.get("surface_container_high", "#2f2921")
c_bg_highest = colors.get("surface_container_highest", "#39342b")
c_fg = colors.get("on_surface", "#ece1d4")
c_muted = colors.get("outline", "#9a8f80")
c_border = colors.get("outline_variant", "#4e4639")
c_primary = colors.get("primary", "#ecc06c")
c_primary_container = colors.get("primary_container", "#5a4300")
c_secondary = colors.get("secondary", "#d9c4a0")
c_tertiary = colors.get("tertiary", "#b2cfa7")
c_error = colors.get("error", "#ffb4ab")

def hex_to_rgb(hex_str):
    h = hex_str.strip().lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def hex_to_uint(hex_str, alpha=0xFF):
    r, g, b = hex_to_rgb(hex_str)
    return (r << 24) | (g << 16) | (b << 8) | alpha

print("=== Synchronizing Matugen App Themes ===")

# --- 1. FreeCAD ---
try:
    freecad_script = os.path.expanduser("~/.local/share/FreeCAD/v1-1/apply_matugen.py")
    if os.path.exists(freecad_script):
        subprocess.run(["python3", freecad_script], check=True, stdout=subprocess.DEVNULL)
        print("✓ FreeCAD: Theme applied")
except Exception as e:
    print(f"✗ FreeCAD error: {e}")

# --- 2. KiCad ---
try:
    kicad_colors_dir = os.path.expanduser("~/.config/kicad/10.0/colors")
    os.makedirs(kicad_colors_dir, exist_ok=True)
    r, g, b = hex_to_rgb(c_bg)
    theme = {
        "meta": {"version": 3},
        "schematic": {
            "background": f"rgb({r}, {g}, {b})",
            "brightened": f"rgb{hex_to_rgb(c_primary)}",
            "bus": f"rgb{hex_to_rgb(c_tertiary)}",
            "bus_junction": f"rgb{hex_to_rgb(c_tertiary)}",
            "component_body": f"rgb{hex_to_rgb(c_bg_high)}",
            "component_outline": f"rgb{hex_to_rgb(c_primary)}",
            "cursor": f"rgb{hex_to_rgb(c_fg)}",
            "dnp_marker": f"rgba({hex_to_rgb(c_error)[0]}, {hex_to_rgb(c_error)[1]}, {hex_to_rgb(c_error)[2]}, 0.8)",
            "erc_error": f"rgb{hex_to_rgb(c_error)}",
            "erc_warning": f"rgb{hex_to_rgb(c_primary)}",
            "fields": f"rgb{hex_to_rgb(c_secondary)}",
            "grid": f"rgb{hex_to_rgb(c_bg_high)}",
            "grid_axes": f"rgb{hex_to_rgb(c_border)}",
            "hidden": f"rgb{hex_to_rgb(c_muted)}",
            "junction": f"rgb{hex_to_rgb(c_primary)}",
            "label_global": f"rgb{hex_to_rgb(c_primary)}",
            "label_hier": f"rgb{hex_to_rgb(c_secondary)}",
            "label_local": f"rgb{hex_to_rgb(c_tertiary)}",
            "net_name": f"rgb{hex_to_rgb(c_fg)}",
            "no_connect": f"rgb{hex_to_rgb(c_error)}",
            "note": f"rgb{hex_to_rgb(c_muted)}",
            "op_currents": f"rgb{hex_to_rgb(c_primary)}",
            "op_voltages": f"rgb{hex_to_rgb(c_tertiary)}",
            "pin": f"rgb{hex_to_rgb(c_primary)}",
            "pin_name": f"rgb{hex_to_rgb(c_fg)}",
            "pin_number": f"rgb{hex_to_rgb(c_secondary)}",
            "reference": f"rgb{hex_to_rgb(c_primary)}",
            "shadow": f"rgba({r}, {g}, {b}, 0.6)",
            "sheet": f"rgb{hex_to_rgb(c_border)}",
            "sheet_background": f"rgb{hex_to_rgb(c_bg_card)}",
            "sheet_fields": f"rgb{hex_to_rgb(c_secondary)}",
            "sheet_filename": f"rgb{hex_to_rgb(c_secondary)}",
            "sheet_label": f"rgb{hex_to_rgb(c_primary)}",
            "sheet_name": f"rgb{hex_to_rgb(c_fg)}",
            "value": f"rgb{hex_to_rgb(c_fg)}",
            "wire": f"rgb{hex_to_rgb(c_primary)}",
            "worksheet": f"rgb{hex_to_rgb(c_border)}"
        },
        "board": {
            "anchor": f"rgb{hex_to_rgb(c_primary)}",
            "aux_items": f"rgb{hex_to_rgb(c_fg)}",
            "b_adhes": f"rgb{hex_to_rgb(c_secondary)}",
            "b_crtyd": f"rgb{hex_to_rgb(c_tertiary)}",
            "b_fab": f"rgb{hex_to_rgb(c_secondary)}",
            "b_mask": f"rgba({hex_to_rgb(c_border)[0]}, {hex_to_rgb(c_border)[1]}, {hex_to_rgb(c_border)[2]}, 0.7)",
            "b_paste": f"rgb{hex_to_rgb(c_primary)}",
            "b_silks": f"rgb{hex_to_rgb(c_secondary)}",
            "background": f"rgb({r}, {g}, {b})",
            "cmts_user": f"rgb{hex_to_rgb(c_muted)}",
            "copper": {
                "b": f"rgba({hex_to_rgb(c_tertiary)[0]}, {hex_to_rgb(c_tertiary)[1]}, {hex_to_rgb(c_tertiary)[2]}, 0.85)",
                "f": f"rgba({hex_to_rgb(c_primary)[0]}, {hex_to_rgb(c_primary)[1]}, {hex_to_rgb(c_primary)[2]}, 0.85)"
            },
            "cursor": f"rgb{hex_to_rgb(c_fg)}",
            "dwgs_user": f"rgb{hex_to_rgb(c_muted)}",
            "edge_cuts": f"rgb{hex_to_rgb(c_primary)}",
            "f_adhes": f"rgb{hex_to_rgb(c_secondary)}",
            "f_crtyd": f"rgb{hex_to_rgb(c_primary)}",
            "f_fab": f"rgb{hex_to_rgb(c_secondary)}",
            "f_mask": f"rgba({hex_to_rgb(c_border)[0]}, {hex_to_rgb(c_border)[1]}, {hex_to_rgb(c_border)[2]}, 0.7)",
            "f_paste": f"rgb{hex_to_rgb(c_primary)}",
            "f_silks": f"rgb{hex_to_rgb(c_fg)}",
            "grid": f"rgb{hex_to_rgb(c_bg_high)}",
            "grid_axes": f"rgb{hex_to_rgb(c_border)}",
            "no_connect": f"rgb{hex_to_rgb(c_error)}",
            "pad_back": f"rgba({hex_to_rgb(c_tertiary)[0]}, {hex_to_rgb(c_tertiary)[1]}, {hex_to_rgb(c_tertiary)[2]}, 0.8)",
            "pad_front": f"rgba({hex_to_rgb(c_primary)[0]}, {hex_to_rgb(c_primary)[1]}, {hex_to_rgb(c_primary)[2]}, 0.8)",
            "pad_through_hole": f"rgb{hex_to_rgb(c_secondary)}",
            "ratsnest": f"rgb{hex_to_rgb(c_muted)}",
            "via_through": f"rgb{hex_to_rgb(c_primary)}",
            "worksheet": f"rgb{hex_to_rgb(c_border)}"
        }
    }
    with open(os.path.join(kicad_colors_dir, "Matugen.json"), "w") as f:
        json.dump(theme, f, indent=2)
    print("✓ KiCad: Matugen theme updated")
except Exception as e:
    print(f"✗ KiCad error: {e}")

# --- 3. Qucs-S ---
try:
    qucs_path = os.path.expanduser("~/.config/qucs/qucs_s.conf")
    if os.path.exists(qucs_path):
        with open(qucs_path, "r") as f:
            lines = f.readlines()
        updates = {
            "BGColor": c_bg,
            "GridColor": c_border,
            "Attribute": c_tertiary,
            "Character": c_error,
            "Comment": c_muted,
            "Directive": c_primary,
            "Integer": c_secondary,
            "Real": c_primary,
            "String": c_tertiary,
            "Task": c_error,
            "Type": c_secondary
        }
        new_lines = []
        for line in lines:
            if "=" in line:
                k, v = line.strip().split("=", 1)
                if k in updates:
                    new_lines.append(f"{k}={updates[k]}\n")
                    continue
            new_lines.append(line)
        with open(qucs_path, "w") as f:
            f.writelines(new_lines)
        print("✓ Qucs-S: Colors updated")
except Exception as e:
    print(f"✗ Qucs-S error: {e}")

# --- 4. Arduino IDE 2.x ---
try:
    import zipfile
    ard_dir = os.path.expanduser("~/.arduinoIDE")
    plugin_dir = os.path.join(ard_dir, "plugins/theme-matugen")
    ext_dir = os.path.join(ard_dir, "extensions")
    themes_dir = os.path.join(plugin_dir, "themes")
    os.makedirs(themes_dir, exist_ok=True)
    os.makedirs(ext_dir, exist_ok=True)

    theme_json = {
        "name": "Matugen Dark",
        "type": "dark",
        "colors": {
            "focusBorder": c_primary,
            "foreground": c_fg,
            "selection.background": c_primary_container,
            "descriptionForeground": c_muted,
            "errorForeground": c_error,
            "activityBar.background": c_bg,
            "activityBar.foreground": c_fg,
            "activityBar.inactiveForeground": c_muted,
            "activityBar.activeBorder": c_primary,
            "activityBarBadge.background": c_primary,
            "activityBarBadge.foreground": "#412d00",
            "sideBar.background": c_bg_low,
            "sideBar.foreground": c_fg,
            "sideBar.border": c_border,
            "sideBarTitle.foreground": c_fg,
            "sideBarSectionHeader.background": c_bg_card,
            "sideBarSectionHeader.foreground": c_fg,
            "sideBarSectionHeader.border": c_border,
            "editorGroupHeader.tabsBackground": c_bg,
            "editorGroupHeader.tabsBorder": c_border,
            "tab.activeBackground": c_bg_card,
            "tab.activeForeground": c_fg,
            "tab.activeBorderTop": c_primary,
            "tab.inactiveBackground": c_bg,
            "tab.inactiveForeground": c_muted,
            "tab.border": c_border,
            "editor.background": c_bg,
            "editor.foreground": c_fg,
            "editorLineNumber.foreground": c_muted,
            "editorLineNumber.activeForeground": c_primary,
            "editorCursor.foreground": c_primary,
            "editor.selectionBackground": f"{c_primary_container}80",
            "editor.lineHighlightBackground": f"{c_bg_card}80",
            "editorWidget.background": c_bg_card,
            "editorWidget.border": c_border,
            "statusBar.background": c_bg,
            "statusBar.foreground": c_fg,
            "statusBar.border": c_border,
            "statusBarItem.hoverBackground": c_bg_high,
            "titleBar.activeBackground": c_bg,
            "titleBar.activeForeground": c_fg,
            "titleBar.border": c_border,
            "panel.background": c_bg_low,
            "panel.border": c_border,
            "panelTitle.activeForeground": c_primary,
            "terminal.background": c_bg,
            "terminal.foreground": c_fg,
            "input.background": c_bg_card,
            "input.border": c_border,
            "input.foreground": c_fg,
            "inputOption.activeBorder": c_primary,
            "dropdown.background": c_bg_card,
            "dropdown.border": c_border,
            "dropdown.foreground": c_fg,
            "list.hoverBackground": c_bg_high,
            "list.activeSelectionBackground": c_primary_container,
            "list.activeSelectionForeground": c_fg,
            "list.inactiveSelectionBackground": c_bg_high,
            "button.background": c_primary,
            "button.foreground": "#412d00",
            "button.hoverBackground": f"{c_primary}dd",
            "badge.background": c_primary,
            "badge.foreground": "#412d00"
        },
        "tokenColors": [
            {
                "name": "Comments",
                "scope": ["comment", "punctuation.definition.comment"],
                "settings": {"foreground": c_muted, "fontStyle": "italic"}
            },
            {
                "name": "Keywords & Storage",
                "scope": ["keyword", "storage.type", "storage.modifier", "keyword.control"],
                "settings": {"foreground": c_primary}
            },
            {
                "name": "Strings",
                "scope": ["string", "punctuation.definition.string"],
                "settings": {"foreground": c_tertiary}
            },
            {
                "name": "Numbers & Constants",
                "scope": ["constant.numeric", "constant.language", "constant.character"],
                "settings": {"foreground": c_secondary}
            },
            {
                "name": "Functions",
                "scope": ["entity.name.function", "support.function"],
                "settings": {"foreground": c_tertiary}
            },
            {
                "name": "Types & Classes",
                "scope": ["entity.name.type", "support.type", "entity.name.class", "support.class"],
                "settings": {"foreground": c_primary}
            },
            {
                "name": "Variables & Parameters",
                "scope": ["variable", "variable.parameter", "entity.name.variable"],
                "settings": {"foreground": c_fg}
            },
            {
                "name": "Arduino Builtins & Pins",
                "scope": ["support.constant.arduino", "entity.name.function.arduino"],
                "settings": {"foreground": c_primary, "fontStyle": "bold"}
            }
        ]
    }

    pkg_json = {
        "name": "theme-matugen",
        "displayName": "Matugen Dark",
        "description": "Matugen Material Design 3 theme for Arduino IDE",
        "version": "1.0.0",
        "publisher": "matugen",
        "engines": {
            "vscode": "^1.60.0",
            "theiaPlugin": "^1.0.0"
        },
        "categories": ["Themes"],
        "contributes": {
            "themes": [
                {
                    "id": "matugen-dark",
                    "label": "Matugen Dark",
                    "uiTheme": "vs-dark",
                    "path": "./themes/matugen-dark.json"
                }
            ]
        }
    }

    manifest_xml = '''<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Id="theme-matugen" Version="1.0.0" Publisher="matugen" Language="en-US"/>
    <DisplayName>Matugen Dark</DisplayName>
    <Description xml:space="preserve">Matugen theme for Arduino IDE</Description>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Code"/>
  </Installation>
  <Dependencies/>
  <Assets>
    <Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/>
  </Assets>
</PackageManifest>'''

    content_types_xml = '''<?xml version="1.0" encoding="utf-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="json" ContentType="application/json"/>
  <Default Extension="vsixmanifest" ContentType="text/xml"/>
  <Override PartName="/extension/package.json" ContentType="application/json"/>
</Types>'''

    with open(os.path.join(plugin_dir, "package.json"), "w") as f:
        json.dump(pkg_json, f, indent=2)
    with open(os.path.join(plugin_dir, "themes/matugen-dark.json"), "w") as f:
        json.dump(theme_json, f, indent=2)

    vsix_path = os.path.join(ext_dir, "matugen-theme-1.0.0.vsix")
    with zipfile.ZipFile(vsix_path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", content_types_xml)
        zf.writestr("extension.vsixmanifest", manifest_xml)
        zf.writestr("extension/package.json", json.dumps(pkg_json, indent=2))
        zf.writestr("extension/themes/matugen-dark.json", json.dumps(theme_json, indent=2))

    deployed_theme = os.path.expanduser("~/.arduinoIDE/deployedPlugins/matugen-theme-1.0.0/extension/themes/matugen-dark.json")
    if os.path.exists(os.path.dirname(deployed_theme)):
        with open(deployed_theme, "w") as f:
            json.dump(theme_json, f, indent=2)

    ard_path = os.path.join(ard_dir, "settings.json")
    if os.path.exists(ard_path):
        with open(ard_path, "r") as f:
            cfg = json.load(f)
        cfg["workbench.colorTheme"] = "Matugen Dark"
        with open(ard_path, "w") as f:
            json.dump(cfg, f, indent=2)
    print("✓ Arduino IDE: Matugen Dark theme extension updated")
except Exception as e:
    print(f"✗ Arduino IDE error: {e}")

# --- 5. Calibre ---
try:
    cal_dir = os.path.expanduser("~/.config/calibre")
    palette_data = {
        "dark": {
            "palette": {
                "Accent": c_primary,
                "AlternateBase": c_bg_low,
                "Base": c_bg,
                "BrightText": c_error,
                "Button": c_bg_card,
                "ButtonText": c_fg,
                "ButtonText-disabled": c_muted,
                "Highlight": c_primary,
                "HighlightedText": c_bg,
                "HighlightedText-disabled": c_muted,
                "Link": c_primary,
                "LinkVisited": c_secondary,
                "PlaceholderText": c_muted,
                "Text": c_fg,
                "Text-disabled": c_muted,
                "ToolTipBase": c_bg_card,
                "ToolTipText": c_fg,
                "Window": c_bg,
                "WindowText": c_fg,
                "WindowText-disabled": c_muted
            },
            "use_custom": True
        },
        "light": {
            "palette": {},
            "use_custom": False
        }
    }
    palette_file = os.path.join(cal_dir, "Matugen.calibre-palette")
    with open(palette_file, "w") as f:
        json.dump(palette_data, f, indent=2)

    cal_json = os.path.join(cal_dir, "gui.json")
    if os.path.exists(cal_json):
        with open(cal_json, "r") as f:
            cfg = json.load(f)
        cfg["ui_style"] = "calibre-style"
        cfg["color_palette"] = "dark"
        cfg["dark_palette_name"] = "__current__"
        if "dark_palettes" not in cfg or not isinstance(cfg["dark_palettes"], dict):
            cfg["dark_palettes"] = {}
        cfg["dark_palettes"]["__current__"] = palette_data["dark"]["palette"]
        cfg["dark_palettes"]["Matugen"] = palette_data["dark"]["palette"]
        with open(cal_json, "w") as f:
            json.dump(cfg, f, indent=2)
        print("✓ Calibre: Palette and .calibre-palette updated")
except Exception as e:
    print(f"✗ Calibre error: {e}")

# --- 6. Calibre TUI ---
try:
    tui_path = os.path.expanduser("~/.config/calibre-tui/theme.toml")
    if os.path.exists(tui_path):
        tui_content = f"""foreground = "{c_fg}"
background = "{c_bg}"
accent = "{c_primary}"
muted = "{c_muted}"

[search]
border = "{c_primary}"
title = "{c_primary}"
text = "{c_fg}"

[command]
border = "{c_primary}"
title = "{c_primary}"
text = "{c_fg}"
prefix = "{c_primary}"
suggestion = "{c_muted}"

[table]
border = "{c_border}"
title = "{c_primary}"
header = "{c_primary}"
title_field = "{c_fg}"
authors_field = "{c_secondary}"
series_field = "{c_fg}"
formats_field = "{c_primary}"
tags_field = "{c_tertiary}"

[row]
hover_foreground = "{c_fg}"
hover_background = "{c_bg_high}"
selected_foreground = "{c_fg}"
selected_background = "{c_primary_container}"
selected_hover_foreground = "{c_fg}"
selected_hover_background = "{c_bg_high}"

[highlight]
normal = "{c_error}"
hover = "{c_primary}"
selected = "{c_primary}"
selected_hover = "{c_error}"

[footer]
message = "{c_muted}"
which_key_background = "{c_bg}"
which_key_foreground = "{c_fg}"
which_key_key = "{c_primary}"
which_key_separator = "{c_muted}"
which_key_description = "{c_fg}"
which_key_separator_text = "  "
which_key_columns = 3

[completion]
foreground = "{c_fg}"
background = "{c_bg}"
selected_foreground = "{c_fg}"
selected_background = "{c_primary_container}"

[help]
background = "{c_bg}"
border = "{c_primary}"
key = "{c_primary}"
description = "{c_fg}"
muted = "{c_muted}"
"""
        with open(tui_path, "w") as f:
            f.write(tui_content)
        print("✓ Calibre TUI: Theme updated")
except Exception as e:
    print(f"✗ Calibre TUI error: {e}")

# --- 7. OrcaSlicer ---
try:
    user_id = "e8faced8-1f03-4a75-8bcf-cf1c38c194c2"
    filament_dir = os.path.expanduser(f"~/.config/OrcaSlicer/user/{user_id}/filament")
    os.makedirs(filament_dir, exist_ok=True)
    palettes = [
        ("Matugen Gold PLA", c_primary),
        ("Matugen Sage PLA", c_tertiary),
        ("Matugen Beige PLA", c_secondary),
        ("Matugen Coral PLA", c_error),
        ("Matugen Surface PLA", c_bg),
    ]
    printers = [
        ("BBL A1", "Bambu PLA Basic @BBL A1"),
        ("BBL A1M", "Bambu PLA Basic @BBL A1M"),
    ]
    for label, hex_color in palettes:
        for p_tag, base_preset in printers:
            preset_name = f"{label} @{p_tag}"
            json_path = os.path.join(filament_dir, f"{preset_name}.json")
            filament_data = {
                "type": "filament",
                "name": preset_name,
                "inherits": base_preset,
                "from": "User",
                "instantiation": "true",
                "filament_colour": [hex_color],
                "default_filament_colour": [hex_color]
            }
            with open(json_path, "w") as f:
                json.dump(filament_data, f, indent=4)
    print("✓ OrcaSlicer: 10 filament color presets updated")
except Exception as e:
    print(f"✗ OrcaSlicer error: {e}")

print("=== Synchronization Complete ===")
