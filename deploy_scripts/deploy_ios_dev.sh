#!/bin/bash

# ❌ Exit immediately if any command fails
set -e

# =============================
# 🔧 CONFIGURATION
# =============================
APPLE_ID="" # email
APP_SPECIFIC_PASSWORD="" # app specific password in apple developer account

# Output IPA path
IPA_PATH="build/ios/ipa/pinto_app.ipa"

# =============================
# 🏗️ BUILD IPA
# =============================
echo "🚀 Building Flutter iOS IPA (Release mode)..."

fvm flutter build ipa --release \
  --flavor dev \
  --dart-define=flavor=dev \
  -t lib/main.dart

# Validate build success
if [ ! -f "$IPA_PATH" ]; then
  echo "❌ IPA file not found at path: $IPA_PATH"
  exit 1
fi

# =============================
# 📤 UPLOAD TO TESTFLIGHT
# =============================
echo "📦 Uploading IPA to TestFlight via altool..."
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -t ios \
  -u "$APPLE_ID" \
  -p "$APP_SPECIFIC_PASSWORD" \
  --verbose

echo "✅ Upload completed successfully! The build is now processing on TestFlight."
