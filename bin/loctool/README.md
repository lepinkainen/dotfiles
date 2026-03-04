# LocationCLI

Minimal macOS app bundle that prints the current device location as JSON to stdout using CoreLocation.

Needed because CoreLocation permission prompts only work for app bundles, not bare CLI processes.

## Output

```json
{"lat": 60.466, "lon": 25.089, "accuracy_m": 35}
```

On error:

```json
{"error": "Location permission denied or restricted"}
```

## Initial setup

Requires Xcode command-line tools (`xcode-select --install`).

```sh
cd loctool

APP="LocationCLI.app"
mkdir -p "$APP/Contents/MacOS"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>LocationCLI</string>
  <key>CFBundleIdentifier</key><string>dev.local.LocationCLI</string>
  <key>CFBundleExecutable</key><string>LocationCLI</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>NSLocationUsageDescription</key>
  <string>Print current location to stdout.</string>
</dict>
</plist>
PLIST

swiftc main.swift -o "$APP/Contents/MacOS/LocationCLI"
codesign --force --sign - "$APP"
```

## Rebuild after editing main.swift

```sh
cd loctool
mkdir -p LocationCLI.app/Contents/MacOS
swiftc main.swift -o LocationCLI.app/Contents/MacOS/LocationCLI
codesign --force --sign - LocationCLI.app
```

## Permissions

On first run, macOS will prompt to allow location access for LocationCLI. This can also be managed in **System Settings > Privacy & Security > Location Services**.
