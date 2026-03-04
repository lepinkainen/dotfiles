# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

```sh
./build.sh
```

This creates/updates `LocationCLI.app/Contents/MacOS/LocationCLI` and re-signs the bundle. Requires Xcode command-line tools.

## Architecture

Single-file Swift app (`main.swift`) compiled into a macOS app bundle. The bundle structure is required because CoreLocation permission prompts only work for app bundles, not bare CLI processes.

`main.swift` implements a `CLLocationManagerDelegate` that:
1. Requests a single location fix (`requestLocation`)
2. Prints result as JSON to stdout and calls `exit()`

The `RunLoop.main.run()` at the end keeps the process alive until CoreLocation delivers a result or error asynchronously.

Exit codes: `0` = success, `1` = location error, `2` = permission denied/restricted.

## App bundle

- `LocationCLI.app/Contents/Info.plist` — bundle metadata and `NSLocationUsageDescription` (required for the permission prompt)
- `LocationCLI.app/Contents/MacOS/LocationCLI` — compiled binary (not committed)

The bundle is ad-hoc signed (`codesign --sign -`) after each build.
