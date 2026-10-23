#!/bin/bash

# อ่าน version จาก pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d '+' -f 1)

if [ -z "$VERSION" ]; then
    echo "get version from pubspec.yaml please check file"
    exit 1
fi

if [ -f .env ]; then
    cp .env .env.bak
fi

if [ -f .env.prod ]; then
    cp .env.prod .env
else
    echo ".env.prod not found"
    exit 1
fi

fvm use 3.38.9
fvm flutter build apk --flavor prod

BUILD_STATUS=$?


if [ -f .env.bak ]; then
    mv .env.bak .env
else
    rm -f .env
fi


if [ $BUILD_STATUS -eq 0 ]; then
    mkdir -p build/app/outputs/flutter-apk/prod
    mv build/app/outputs/flutter-apk/app-prod-release.apk build/app/outputs/flutter-apk/prod/mobile_app_standard-${VERSION}.apk
    echo "<| Build Success => build/app/outputs/flutter-apk/prod/mobile_app_standard-${VERSION}.apk |>"
else
    echo "<| build APK failed |>"
    exit 1
fi