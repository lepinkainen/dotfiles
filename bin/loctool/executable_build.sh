#!/bin/sh
set -e

APP="LocationCLI.app"

mkdir -p "$APP/Contents/MacOS"
swiftc main.swift -o "$APP/Contents/MacOS/LocationCLI"
codesign --force --sign - "$APP"
