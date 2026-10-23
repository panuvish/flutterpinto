#!/bin/bash
set -euo pipefail

FLAVOR="prod"

echo "🚀 Uploading ${FLAVOR} flavor via Fastlane..."

cd android
fastlane deploy flavor:${FLAVOR}
cd ..
