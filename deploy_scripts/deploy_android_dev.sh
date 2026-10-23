#!/bin/bash
set -euo pipefail

FLAVOR="dev"

echo "🚀 Uploading ${FLAVOR} flavor via Fastlane..."

cd android
fastlane deploy flavor:${FLAVOR}
cd ..
