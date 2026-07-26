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
APPCAST_PATH="${BUILD_DIR}/appcast.xml"
UPDATES_DIR="${BUILD_DIR}/updates"

verify_code_signature() {
  codesign --verify --strict --verbose=2 "$1"
}

verify_embedded_code() {
  verify_code_signature "${APP_PATH}"

  local sparkle_framework="${APP_PATH}/Contents/Frameworks/Sparkle.framework"
  local sparkle_services="${sparkle_framework}/Versions/B/XPCServices"

  if [ -d "${sparkle_framework}" ]; then
    verify_code_signature "${sparkle_framework}"
  fi

  if [ -d "${sparkle_services}" ]; then
    while IFS= read -r service_path; do
      verify_code_signature "${service_path}"
    done < <(find "${sparkle_services}" -mindepth 1 -maxdepth 1 -type d)
  fi
}

find_sparkle_bin() {
  find ~/Library/Developer/Xcode/DerivedData \
    -path "*/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast" \
    -print -quit 2>/dev/null | xargs -I{} dirname "{}"
}

generate_appcast_if_configured() {
  local sparkle_bin
  local key_file
  local temp_key_file=""

  if [ -z "${SPARKLE_DOWNLOAD_URL_PREFIX:-}" ]; then
    echo "Skipping appcast generation: SPARKLE_DOWNLOAD_URL_PREFIX is not set."
    return
  fi

  sparkle_bin=$(find_sparkle_bin)
  if [ -z "${sparkle_bin}" ]; then
    echo "Skipping appcast generation: Sparkle tools were not found in DerivedData."
    return
  fi

  if [ -n "${SPARKLE_PRIVATE_KEY_FILE:-}" ]; then
    key_file="${SPARKLE_PRIVATE_KEY_FILE}"
  elif [ -n "${SPARKLE_PRIVATE_KEY:-}" ]; then
    temp_key_file=$(mktemp "${TMPDIR:-/tmp}/sparkle-key.XXXXXX")
    printf "%s" "${SPARKLE_PRIVATE_KEY}" > "${temp_key_file}"
    key_file="${temp_key_file}"
  else
    echo "Skipping appcast generation: provide SPARKLE_PRIVATE_KEY or SPARKLE_PRIVATE_KEY_FILE."
    return
  fi

  rm -rf "${UPDATES_DIR}"
  mkdir -p "${UPDATES_DIR}"
  cp "${DMG_PATH}" "${UPDATES_DIR}/"

  "${sparkle_bin}/generate_appcast" \
    --ed-key-file "${key_file}" \
    --download-url-prefix "${SPARKLE_DOWNLOAD_URL_PREFIX}" \
    "${UPDATES_DIR}"

  cp "${UPDATES_DIR}/appcast.xml" "${APPCAST_PATH}"

  if [ -n "${temp_key_file}" ]; then
    rm -f "${temp_key_file}"
  fi

  echo "Generated appcast: ${APPCAST_PATH}"
}

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
verify_embedded_code

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

# Step 12: Generate appcast (optional)
echo "Generating appcast if Sparkle signing is configured..."
generate_appcast_if_configured

# Cleanup
rm -f "${ZIP_PATH}"

echo ""
echo "=== Build Complete ==="
echo "DMG ready for distribution: ${DMG_PATH}"
if [ -f "${APPCAST_PATH}" ]; then
  echo "Appcast ready for distribution: ${APPCAST_PATH}"
fi
echo ""
echo "To verify on another Mac:"
echo "  spctl --assess --type open --verbose=2 '${DMG_PATH}'"
