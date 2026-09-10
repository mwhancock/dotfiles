#!/usr/bin/env python3
import os
import re
import sys
import xml.etree.ElementTree as ET

USER_APPDATA = os.path.expanduser("~/.local/share/FreeCAD/v1-1")
YAML_PATH = os.path.join(USER_APPDATA, "Gui/Stylesheets/parameters/Matugen.yaml")
SRC_QSS = "/usr/share/freecad/Gui/Stylesheets/FreeCAD.qss"
OUT_QSS = os.path.join(USER_APPDATA, "Gui/Stylesheets/Matugen.qss")
PREF_PACK_DIR = os.path.join(USER_APPDATA, "SavedPreferencePacks/Matugen")
PREF_PACK_CFG = os.path.join(PREF_PACK_DIR, "Matugen.cfg")
PREF_PACK_XML = os.path.join(PREF_PACK_DIR, "package.xml")
USER_CFG = os.path.expanduser("~/.config/FreeCAD/v1-1/user.cfg")

def hex_to_uint(hex_str, alpha=0xFF):
    hex_str = hex_str.strip().lstrip("#")
    r = int(hex_str[0:2], 16)
    g = int(hex_str[2:4], 16)
    b = int(hex_str[4:6], 16)
    return (r << 24) | (g << 16) | (b << 8) | alpha

def parse_yaml_params(yaml_path):
    params = {}
    with open(yaml_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if ":" in line:
                k, v = line.split(":", 1)
                k = k.strip()
                v = v.strip().strip('"').strip("'")
                params[k] = v
    return params

def generate_qss(params):
    with open(SRC_QSS, "r", encoding="utf-8") as f:
        qss = f.read()

    # Define all replacements for @Tokens
    token_map = {
        "@3DViewBackgroundRefColor": params.get("3DViewBackgroundRefColor", "#17130b"),
        "@AccentBackgroundColor": params.get("AccentBackgroundColor", "#5a4300"),
        "@AccentColor": params.get("AccentColor", "#ecc06c"),
        "@AccentHoverColor": params.get("AccentHoverColor", "#51452a"),
        "@ActiveTabBackgroundColor": params.get("ActiveTabBackgroundColor", "#2f2921"),
        "@ButtonBorderColor": params.get("ButtonBorderColor", "#4e4639"),
        "@ButtonBorderHooverColor": params.get("ButtonBorderHooverColor", "#9a8f80"),
        "@ButtonBottomBackgroundColor": params.get("ButtonBottomBackgroundColor", "#241f17"),
        "@ButtonTopBackgroundColor": params.get("ButtonTopBackgroundColor", "#2f2921"),
        "@ButtonBackgroundHooverColor": params.get("ButtonBackgroundHooverColor", "#3a342b"),
        "@CheckBoxBackgroundColor": params.get("CheckBoxBackgroundColor", "#201b13"),
        "@CheckBoxBorderColor": params.get("CheckBoxBorderColor", "#4e4639"),
        "@CheckedButtonBottomBackgroundColor": params.get("CheckedButtonBottomBackgroundColor", "#17130b"),
        "@CheckedButtonTopBackgroundColor": params.get("CheckedButtonTopBackgroundColor", "#201b13"),
        "@DefaultButtonBorderColor": params.get("DefaultButtonBorderColor", "#ecc06c"),
        "@DefaultButtonBottomBackgroundColor": params.get("DefaultButtonBottomBackgroundColor", "#2f2921"),
        "@DefaultButtonTopBackgroundColor": params.get("DefaultButtonTopBackgroundColor", "#3a342b"),
        "@DialogBackgroundColor": params.get("DialogBackgroundColor", "#241f17"),
        "@GeneralAlternateBackgroundColor": params.get("GeneralAlternateBackgroundColor", "#201b13"),
        "@GeneralBackgroundColor": params.get("GeneralBackgroundColor", "#17130b"),
        "@GeneralBackgroundHoverColor": params.get("GeneralBackgroundHoverColor", "#3a342b"),
        "@GeneralBorderColor": params.get("GeneralBorderColor", "#4e4639"),
        "@GeneralBorderHoverColor": params.get("GeneralBorderHoverColor", "#9a8f80"),
        "@GeneralDisabledBackgroundColor": params.get("GeneralDisabledBackgroundColor", "#120e07"),
        "@GeneralGridLinesColor": params.get("GeneralGridLinesColor", "#2f2921"),
        "@GeneralHeaderBackgroundColor": params.get("GeneralHeaderBackgroundColor", "#17130b"),
        "@GroupboxBackgroundColor": params.get("GroupboxBackgroundColor", "#201b13"),
        "@GroupboxBorderColor": params.get("GroupboxBorderColor", "#4e4639"),
        "@IconsLocationFolderName": params.get("IconsLocationFolderName", "images_classic"),
        "@InActiveTabBackgroundColor": params.get("InActiveTabBackgroundColor", "#241f17"),
        "@InputFieldBorderRadius": params.get("InputFieldBorderRadius", "4px"),
        "@MenuBackgroundColor": params.get("MenuBackgroundColor", "#120e07"),
        "@PrimaryColor": params.get("PrimaryColor", "#17130b"),
        "@PrimaryColorDarken1": params.get("PrimaryColorDarken1", "#120e07"),
        "@PrimaryColorDarken2": params.get("PrimaryColorDarken2", "#120e07"),
        "@PrimaryColorDarken3": params.get("PrimaryColorDarken3", "#120e07"),
        "@PrimaryColorDarken4": params.get("PrimaryColorDarken4", "#120e07"),
        "@PrimaryColorDarken5": params.get("PrimaryColorDarken5", "#120e07"),
        "@PrimaryColorDarken6": params.get("PrimaryColorDarken6", "#120e07"),
        "@PrimaryColorLighten1": params.get("PrimaryColorLighten1", "#201b13"),
        "@PrimaryColorLighten2": params.get("PrimaryColorLighten2", "#241f17"),
        "@PrimaryColorLighten3": params.get("PrimaryColorLighten3", "#2f2921"),
        "@PrimaryColorLighten4": params.get("PrimaryColorLighten4", "#3a342b"),
        "@PrimaryColorLighten5": params.get("PrimaryColorLighten5", "#ecc06c"),
        "@PrimaryColorLighten6": params.get("PrimaryColorLighten6", "#ece1d4"),
        "@RadioButtonBackgroundColor": params.get("RadioButtonBackgroundColor", "#201b13"),
        "@RadioButtonBorderColor": params.get("RadioButtonBorderColor", "#4e4639"),
        "@ScrollbarBackgroundColor": params.get("ScrollbarBackgroundColor", "#120e07"),
        "@SketcherConflictingConstraintsColor": params.get("SketcherConflictingConstraintsColor", "#ffb4ab"),
        "@SketcherEmptySketchColor": params.get("SketcherEmptySketchColor", "#d1c5b4"),
        "@SketcherFullyConstrainedColor": params.get("SketcherFullyConstrainedColor", "#b2cfa7"),
        "@SketcherMalformedConstraintsColor": params.get("SketcherMalformedConstraintsColor", "#ffb4ab"),
        "@SketcherPartiallyRedundantConstraintsColor": params.get("SketcherPartiallyRedundantConstraintsColor", "#d9c4a0"),
        "@SketcherRedundantConstraintsColor": params.get("SketcherRedundantConstraintsColor", "#ecc06c"),
        "@SketcherSolverFailedColor": params.get("SketcherSolverFailedColor", "#ffb4ab"),
        "@SketcherUnderConstrainedColor": params.get("SketcherUnderConstrainedColor", "#ece1d4"),
        "@StylesheetIconsColor": params.get("StylesheetIconsColor", "white"),
        "@TabbarBackgroundColor": params.get("TabbarBackgroundColor", "#120e07"),
        "@TextDisabledColor": params.get("TextDisabledColor", "#9a8f80"),
        "@TextEditFieldBackgroundColor": params.get("TextEditFieldBackgroundColor", "#201b13"),
        "@TextForegroundColor": params.get("TextForegroundColor", "#ece1d4"),
        "@TextSelectBackgroundColor": params.get("TextSelectBackgroundColor", "#5a4300"),
        "@TextUrlColor": params.get("TextUrlColor", "#ecc06c"),
        "@ToolbarButtonsPadding": params.get("ToolbarButtonsPadding", "2px"),
        "@ToolButtonCheckedBackground": params.get("ToolButtonCheckedBackground", "#2f2921"),
        "@ToolButtonCheckedBorderColor": params.get("ToolButtonCheckedBorderColor", "#ecc06c"),
    }

    for token, val in token_map.items():
        qss = qss.replace(token, val)

    os.makedirs(os.path.dirname(OUT_QSS), exist_ok=True)
    with open(OUT_QSS, "w", encoding="utf-8") as f:
        f.write(qss)
    print(f"Generated {OUT_QSS}")

def generate_preference_pack(params):
    os.makedirs(PREF_PACK_DIR, exist_ok=True)
    
    bg_hex = params.get("GeneralBackgroundColor", "#17130b")
    accent_hex = params.get("AccentColor", "#ecc06c")
    secondary_hex = params.get("SketcherPartiallyRedundantConstraintsColor", "#d9c4a0")
    tertiary_hex = params.get("SketcherFullyConstrainedColor", "#b2cfa7")
    error_hex = params.get("SketcherConflictingConstraintsColor", "#ffb4ab")
    fg_hex = params.get("TextForegroundColor", "#ece1d4")
    muted_hex = params.get("TextDisabledColor", "#9a8f80")
    surface_container = params.get("DialogBackgroundColor", "#241f17")
    surface_high = params.get("ButtonTopBackgroundColor", "#2f2921")
    
    bg_uint = hex_to_uint(bg_hex)
    accent_uint = hex_to_uint(accent_hex)
    secondary_uint = hex_to_uint(secondary_hex)
    tertiary_uint = hex_to_uint(tertiary_hex)
    error_uint = hex_to_uint(error_hex)
    fg_uint = hex_to_uint(fg_hex)
    muted_uint = hex_to_uint(muted_hex)
    surface_high_uint = hex_to_uint(surface_high)

    cfg_content = f"""<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<FCParameters>
  <FCParamGroup Name="Root">
    <FCParamGroup Name="BaseApp">
      <FCParamGroup Name="Preferences">
        <FCParamGroup Name="NaviCube">
          <FCUInt Name="Color" Value="{surface_high_uint}"/>
        </FCParamGroup>
        <FCParamGroup Name="Editor">
          <FCUInt Name="Block comment" Value="{muted_uint}"/>
          <FCUInt Name="Bookmark" Value="{accent_uint}"/>
          <FCUInt Name="Breakpoint" Value="{error_uint}"/>
          <FCUInt Name="Character" Value="{tertiary_uint}"/>
          <FCUInt Name="Class name" Value="{secondary_uint}"/>
          <FCUInt Name="Comment" Value="{muted_uint}"/>
          <FCUInt Name="Current line highlight" Value="{surface_high_uint}"/>
          <FCUInt Name="Define name" Value="{accent_uint}"/>
          <FCUInt Name="Keyword" Value="{accent_uint}"/>
          <FCUInt Name="Number" Value="{secondary_uint}"/>
          <FCUInt Name="Operator" Value="{fg_uint}"/>
          <FCUInt Name="Python error" Value="{error_uint}"/>
          <FCUInt Name="Python output" Value="{fg_uint}"/>
          <FCUInt Name="String" Value="{tertiary_uint}"/>
          <FCUInt Name="Text" Value="{fg_uint}"/>
        </FCParamGroup>
        <FCParamGroup Name="MainWindow">
          <FCText Name="OverlayActiveStyleSheet">Freecad Overlay.qss</FCText>
          <FCText Name="QtStyle">FreeCAD</FCText>
          <FCText Name="StyleSheet">Matugen.qss</FCText>
          <FCText Name="Theme">Matugen</FCText>
        </FCParamGroup>
        <FCParamGroup Name="OutputWindow">
          <FCUInt Name="colorError" Value="{error_uint}"/>
          <FCUInt Name="colorLogging" Value="{tertiary_uint}"/>
          <FCUInt Name="colorText" Value="{fg_uint}"/>
          <FCUInt Name="colorWarning" Value="{accent_uint}"/>
        </FCParamGroup>
        <FCParamGroup Name="Themes">
          <FCUInt Name="ThemeAccentColor1" Value="{accent_uint}"/>
          <FCUInt Name="ThemeAccentColor2" Value="{tertiary_uint}"/>
          <FCUInt Name="ThemeAccentColor3" Value="{secondary_uint}"/>
        </FCParamGroup>
        <FCParamGroup Name="TreeView">
          <FCInt Name="FontSize" Value="11"/>
          <FCInt Name="ItemBackgroundPadding" Value="11"/>
          <FCUInt Name="TreeActiveColor" Value="{accent_uint}"/>
          <FCUInt Name="TreeEditColor" Value="{tertiary_uint}"/>
        </FCParamGroup>
        <FCParamGroup Name="View">
          <FCBool Name="Gradient" Value="0"/>
          <FCBool Name="RadialGradient" Value="0"/>
          <FCBool Name="Simple" Value="1"/>
          <FCBool Name="UseBackgroundColorMid" Value="0"/>
          <FCUInt Name="AnnotationTextColor" Value="{fg_uint}"/>
          <FCUInt Name="AxisLetterColor" Value="{accent_uint}"/>
          <FCUInt Name="BackgroundColor" Value="{bg_uint}"/>
          <FCUInt Name="BoundingBoxColor" Value="{muted_uint}"/>
          <FCUInt Name="CbLabelColor" Value="{fg_uint}"/>
          <FCUInt Name="ConstrainedDimColor" Value="{accent_uint}"/>
          <FCUInt Name="ConstrainedIcoColor" Value="{accent_uint}"/>
          <FCUInt Name="ConstructionColor" Value="{secondary_uint}"/>
          <FCUInt Name="CreateLineColor" Value="{fg_uint}"/>
          <FCUInt Name="CursorCrosshairColor" Value="{fg_uint}"/>
          <FCUInt Name="CursorTextColor" Value="{fg_uint}"/>
          <FCUInt Name="DeactivatedConstrDimColor" Value="{muted_uint}"/>
          <FCUInt Name="DefaultShapeColor" Value="{muted_uint}"/>
          <FCUInt Name="EditedEdgeColor" Value="{fg_uint}"/>
          <FCUInt Name="EditedVertexColor" Value="{accent_uint}"/>
          <FCUInt Name="ExprBasedConstrDimColor" Value="{error_uint}"/>
          <FCUInt Name="ExternalColor" Value="{secondary_uint}"/>
          <FCUInt Name="FullyConstrainedColor" Value="{tertiary_uint}"/>
          <FCUInt Name="FullyConstraintConstructionElementColor" Value="{secondary_uint}"/>
          <FCUInt Name="FullyConstraintConstructionPointColor" Value="{accent_uint}"/>
          <FCUInt Name="FullyConstraintElementColor" Value="{tertiary_uint}"/>
          <FCUInt Name="FullyConstraintInternalAlignmentColor" Value="{secondary_uint}"/>
          <FCUInt Name="HighlightColor" Value="{tertiary_uint}"/>
          <FCUInt Name="InternalAlignedGeoColor" Value="{secondary_uint}"/>
          <FCUInt Name="InvalidSketchColor" Value="{error_uint}"/>
          <FCUInt Name="NonDrivingConstrDimColor" Value="{muted_uint}"/>
          <FCUInt Name="SelectionColor" Value="{accent_uint}"/>
          <FCUInt Name="SketchEdgeColor" Value="{fg_uint}"/>
          <FCUInt Name="SketchVertexColor" Value="{accent_uint}"/>
        </FCParamGroup>
      </FCParamGroup>
    </FCParamGroup>
  </FCParamGroup>
</FCParameters>
"""
    with open(PREF_PACK_CFG, "w", encoding="utf-8") as f:
        f.write(cfg_content)
    print(f"Generated {PREF_PACK_CFG}")

    xml_content = """<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<package format="1">
  <name>Matugen</name>
  <description>Dynamic Material Design 3 theme generated by Matugen / Noctalia</description>
  <version>1.0.0</version>
  <maintainer email="user@local">Antigravity</maintainer>
  <license file="LICENSE">LGPL2</license>
  <content>
    <preferencepack>
      <name>Matugen</name>
      <type>Theme</type>
      <description>Matches active Matugen / Noctalia desktop palette</description>
      <version>1.0.0</version>
      <tag>matugen</tag>
      <tag>material-you</tag>
      <tag>dark</tag>
    </preferencepack>
  </content>
</package>
"""
    with open(PREF_PACK_XML, "w", encoding="utf-8") as f:
        f.write(xml_content)
    print(f"Generated {PREF_PACK_XML}")

def update_user_config(params):
    import subprocess
    cmd = [
        "freecadcmd", "-c", f"""
import FreeCAD

mw = FreeCAD.ParamGet('User parameter:BaseApp/Preferences/MainWindow')
mw.SetString('StyleSheet', 'Matugen.qss')
mw.SetString('Theme', 'Matugen')
mw.SetString('QtStyle', 'FreeCAD')

view = FreeCAD.ParamGet('User parameter:BaseApp/Preferences/View')
view.SetBool('Gradient', False)
view.SetBool('Simple', True)
view.SetUnsigned('BackgroundColor', {hex_to_uint(params.get("GeneralBackgroundColor", "#17130b"))})
view.SetUnsigned('SelectionColor', {hex_to_uint(params.get("AccentColor", "#ecc06c"))})
view.SetUnsigned('HighlightColor', {hex_to_uint(params.get("SketcherFullyConstrainedColor", "#b2cfa7"))})
view.SetUnsigned('DefaultShapeColor', {hex_to_uint(params.get("TextDisabledColor", "#9a8f80"))})
view.SetUnsigned('SketchEdgeColor', {hex_to_uint(params.get("TextForegroundColor", "#ece1d4"))})
view.SetUnsigned('SketchVertexColor', {hex_to_uint(params.get("AccentColor", "#ecc06c"))})
view.SetUnsigned('FullyConstrainedColor', {hex_to_uint(params.get("SketcherFullyConstrainedColor", "#b2cfa7"))})
view.SetUnsigned('InvalidSketchColor', {hex_to_uint(params.get("SketcherConflictingConstraintsColor", "#ffb4ab"))})
"""
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Updated {USER_CFG}")

def setup_symlinks():
    # Ensure images_classic and images_dark-light are symlinked into user Stylesheets
    user_ss = os.path.join(USER_APPDATA, "Gui/Stylesheets")
    for folder in ["images_classic", "images_dark-light", "overlay"]:
        src = f"/usr/share/freecad/Gui/Stylesheets/{folder}"
        dst = os.path.join(user_ss, folder)
        if not os.path.exists(dst) and os.path.exists(src):
            os.symlink(src, dst)
            print(f"Symlinked {folder} -> {dst}")
    
    # Also symlink Matugen.qss to ~/.local/share/FreeCAD/Gui/Stylesheets/ if desired
    alt_dir = os.path.expanduser("~/.local/share/FreeCAD/Gui/Stylesheets")
    os.makedirs(alt_dir, exist_ok=True)
    alt_qss = os.path.join(alt_dir, "Matugen.qss")
    if not os.path.exists(alt_qss):
        try:
            os.symlink(OUT_QSS, alt_qss)
            print(f"Symlinked Matugen.qss -> {alt_qss}")
        except Exception:
            pass

def main():
    if not os.path.exists(YAML_PATH):
        print(f"Error: {YAML_PATH} does not exist", file=sys.stderr)
        sys.exit(1)
    params = parse_yaml_params(YAML_PATH)
    setup_symlinks()
    generate_qss(params)
    generate_preference_pack(params)
    update_user_config(params)
    print("FreeCAD Matugen theme applied successfully!")

if __name__ == "__main__":
    main()
