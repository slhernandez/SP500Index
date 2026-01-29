#!/bin/bash
set -e

# Configuration
APP_NAME="SP500Index"
SCHEME="SP500Index"
CONFIGURATION="Release"
NOTARY_PROFILE="SP500Index-notarize"

# Derived paths
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
APP_PATH="${EXPORT_PATH}/${APP_NAME}.app"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"
ZIP_PATH="${BUILD_DIR}/${APP_NAME}-notarize.zip"

echo "=== SP500Index Release Build ==="

# Step 1: Clean previous build
echo "Cleaning previous build..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Step 2: Archive
echo "Archiving app..."
xcodebuild archive \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -archivePath "${ARCHIVE_PATH}" \
  -destination "generic/platform=macOS"

# Step 3: Export signed app
echo "Exporting signed app..."
xcodebuild -exportArchive \
  -archivePath "${ARCHIVE_PATH}" \
  -exportPath "${EXPORT_PATH}" \
  -exportOptionsPlist ExportOptions.plist

# Step 4: Verify code signature
echo "Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "${APP_PATH}"

# Step 5: Create ZIP for notarization
echo "Creating ZIP for notarization..."
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

# Step 6: Submit for notarization
echo "Submitting for notarization (this may take a few minutes)..."
xcrun notarytool submit "${ZIP_PATH}" \
  --keychain-profile "${NOTARY_PROFILE}" \
  --wait

# Step 7: Staple the ticket
echo "Stapling notarization ticket..."
xcrun stapler staple "${APP_PATH}"

# Step 8: Verify notarization
echo "Verifying notarization..."
spctl --assess --type open --context context:primary-signature --verbose=2 "${APP_PATH}"

# Step 9: Create DMG
echo "Creating DMG..."
rm -f "${DMG_PATH}"
hdiutil create \
  -volname "${APP_NAME}" \
  -srcfolder "${APP_PATH}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

# Step 10: Notarize DMG
echo "Notarizing DMG..."
xcrun notarytool submit "${DMG_PATH}" \
  --keychain-profile "${NOTARY_PROFILE}" \
  --wait

# Step 11: Staple DMG
echo "Stapling DMG..."
xcrun stapler staple "${DMG_PATH}"

# Cleanup
rm -f "${ZIP_PATH}"

echo ""
echo "=== Build Complete ==="
echo "DMG ready for distribution: ${DMG_PATH}"
echo ""
echo "To verify on another Mac:"
echo "  spctl --assess --type open --verbose=2 '${DMG_PATH}'"
