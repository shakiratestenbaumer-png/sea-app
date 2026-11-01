#!/usr/bin/env bash
# Install Swiss Energy Assistant APK on a connected Android device via ADB.
#
# Usage:
#   ./install.sh              # install on the physical device (default)
#   ./install.sh emulator     # install on the emulator
#   ./install.sh build        # rebuild then install on physical device
#   ./install.sh build emu    # rebuild then install on emulator
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_PATH="${SCRIPT_DIR}/build/app/outputs/flutter-apk/app-release.apk"
PACKAGE="ch.supercharged.sea.swiss_energy_assistant"

TARGET_SERIAL=""
REBUILD=false

for arg in "$@"; do
  case "$arg" in
    build)   REBUILD=true ;;
    emu*)    TARGET_SERIAL="emulator-5554" ;;
    *)       TARGET_SERIAL="$arg" ;;
  esac
done

echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  Swiss Energy Assistant — Android Installer  ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
echo

# Step 1: Check ADB
echo -e "${YELLOW}[1/5] Checking ADB...${NC}"
if ! command -v adb &>/dev/null; then
  echo -e "${RED}  ✗ adb not found. Install Android SDK platform-tools.${NC}"
  exit 1
fi
echo -e "${GREEN}  ✓ ADB found$(adb --version 2>&1 | head -1 | sed 's/.*Version/: Version/')${NC}"

# Step 2: Find device
echo -e "${YELLOW}[2/5] Finding device...${NC}"
DEVICES=$(adb devices | grep -w "device" | grep -v "List")
DEVICE_COUNT=$(echo "$DEVICES" | grep -c "device" || true)

if [ "$DEVICE_COUNT" -eq 0 ]; then
  echo -e "${RED}  ✗ No devices connected. Enable USB debugging and reconnect.${NC}"
  exit 1
fi

if [ -n "$TARGET_SERIAL" ]; then
  if ! echo "$DEVICES" | grep -q "$TARGET_SERIAL"; then
    echo -e "${RED}  ✗ Device '$TARGET_SERIAL' not found. Available:${NC}"
    echo "$DEVICES"
    exit 1
  fi
  ADB_CMD="adb -s $TARGET_SERIAL"
else
  PHYSICAL=$(echo "$DEVICES" | grep -v "emulator" | head -1 | awk '{print $1}')
  if [ -n "$PHYSICAL" ]; then
    TARGET_SERIAL="$PHYSICAL"
  else
    TARGET_SERIAL=$(echo "$DEVICES" | head -1 | awk '{print $1}')
  fi
  ADB_CMD="adb -s $TARGET_SERIAL"
fi

DEVICE_MODEL=$($ADB_CMD shell getprop ro.product.model 2>/dev/null || echo "unknown")
ANDROID_VER=$($ADB_CMD shell getprop ro.build.version.release 2>/dev/null || echo "?")
echo -e "${GREEN}  ✓ Target: $DEVICE_MODEL (Android $ANDROID_VER) [$TARGET_SERIAL]${NC}"

# Step 3: Build (optional)
if [ "$REBUILD" = true ]; then
  echo -e "${YELLOW}[3/5] Building release APK...${NC}"
  cd "$SCRIPT_DIR"
  flutter build apk --release
  echo -e "${GREEN}  ✓ APK built${NC}"
else
  echo -e "${YELLOW}[3/5] Skipping build (use './install.sh build' to rebuild)${NC}"
fi

# Step 4: Check APK
echo -e "${YELLOW}[4/5] Checking APK...${NC}"
if [ ! -f "$APK_PATH" ]; then
  echo -e "${RED}  ✗ APK not found at $APK_PATH${NC}"
  echo -e "${RED}    Run: flutter build apk --release${NC}"
  exit 1
fi
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo -e "${GREEN}  ✓ APK ready ($APK_SIZE)${NC}"

# Step 5: Install
echo -e "${YELLOW}[5/5] Installing on $DEVICE_MODEL...${NC}"

EXISTING=$($ADB_CMD shell pm list packages 2>/dev/null | grep "$PACKAGE" || true)
if [ -n "$EXISTING" ]; then
  echo "  Upgrading existing installation..."
  $ADB_CMD install -r "$APK_PATH" 2>&1
else
  echo "  Fresh install..."
  $ADB_CMD install "$APK_PATH" 2>&1
fi

echo
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Installed! Launching app...               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"

$ADB_CMD shell am start -n "$PACKAGE/.MainActivity" 2>/dev/null \
  || $ADB_CMD shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 2>/dev/null \
  || echo -e "${YELLOW}  Could not auto-launch. Open 'Swiss Energy Assistant' manually.${NC}"

echo
echo -e "${GREEN}Done! The app should now be open on your $DEVICE_MODEL.${NC}"
