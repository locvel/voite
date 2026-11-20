#!/usr/bin/env python3
"""Generate native display-name values from lib/core/constants.dart."""

from html import escape
from pathlib import Path
import plistlib
import re


ROOT = Path(__file__).resolve().parents[1]
constants = (ROOT / "lib/core/constants.dart").read_text(encoding="utf-8")
match = re.search(r"static const String displayName = '([^']+)';", constants)
if match is None:
    raise SystemExit("Could not find AppConstants.displayName")
name = match.group(1)

strings = ROOT / "android/app/src/main/res/values/strings.xml"
strings.parent.mkdir(parents=True, exist_ok=True)
strings.write_text(
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<resources>\n'
    f'    <string name="app_name">{escape(name)}</string>\n'
    '</resources>\n',
    encoding="utf-8",
)

plist = ROOT / "ios/Runner/Info.plist"
with plist.open("rb") as file:
    info = plistlib.load(file)
info["CFBundleDisplayName"] = name
info["CFBundleName"] = name
with plist.open("wb") as file:
    plistlib.dump(info, file, sort_keys=False)
