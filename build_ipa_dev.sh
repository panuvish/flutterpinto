#!/bin/bash

# อ่าน version จาก pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d '+' -f 1)

# ตรวจสอบว่าได้ version หรือไม่
if [ -z "$VERSION" ]; then
    echo "get version from pubspec.yaml please check file"
    exit 1
fi

# backup/restore .env เช่นเดียวกับฝั่ง Android
if [ -f .env ]; then
    cp .env .env.bak
fi

if [ -f .env.dev ]; then
    cp .env.dev .env
else
    echo ".env.dev not found"
    exit 1
fi

# ใช้ FVM เลือกเวอร์ชัน Flutter
fvm use 3.38.9

# build iOS (ipa) — ไม่ใส่ flavor
fvm flutter build ipa --release

BUILD_STATUS=$?

# restore .env กลับ
if [ -f .env.bak ]; then
    mv .env.bak .env.dev
else
    rm -f .env
fi

# ตรวจสอบผลลัพธ์
if [ $BUILD_STATUS -eq 0 ]; then
    # Path output ของ Flutter ipa
    OUTPUT_DIR="build/ios/ipa/dev"
    mkdir -p "$OUTPUT_DIR"
    
    # ตั้งชื่อไฟล์ ipa ใหม่
    mv "$OUTPUT_DIR/Runner.ipa" "$OUTPUT_DIR/mobile_app_standard-${VERSION}.ipa"

    echo "<| Build Success => $OUTPUT_DIR/mobile_app_standard-${VERSION}.ipa |>"
else
    echo "<| build IPA failed |>"
    exit 1
fi
