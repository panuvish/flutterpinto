#!/bin/bash
set -e

# ฟังก์ชันแสดงวิธีใช้งาน
usage() {
  echo "❌ Usage: $0 <feature_name> [--appbar|-a] [--bottombar|-b]"
  echo "  --appbar, -a    Include AppBar in the page (default: true)"
  echo "  --bottombar, -b Include BottomBar in the page (default: true)"
  echo "  --no-appbar, --no-a Do not include AppBar in the page",
  echo "  --no-bottombar, --no-b Do not include BottomBar in the page"
  exit 1
}

# ตรวจสอบว่าใส่ feature_name หรือไม่
if [ -z "$1" ]; then
  usage
fi

FEATURE_NAME="$1"                     # เช่น: login
CLASS_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${FEATURE_NAME:0:1})${FEATURE_NAME:1}"   # Login
PROJECT_PKG="pinto_app"

# ค่าเริ่มต้นสำหรับ AppBar และ BottomBar
INCLUDE_APPBAR=true
INCLUDE_BOTTOMBAR=true

# Parse arguments สำหรับ --appbar และ --bottombar
shift # ข้าม feature_name
while [ $# -gt 0 ]; do
  case "$1" in
    --appbar|-a)
      INCLUDE_APPBAR=true
      INCLUDE_BOTTOMBAR=false
      ;;
    --no-appbar|--no-a)
      INCLUDE_APPBAR=false
      ;;
    --bottombar|-b)
      INCLUDE_BOTTOMBAR=true
      INCLUDE_APPBAR=false
      ;;
    --no-bottombar|--no-b)
      INCLUDE_BOTTOMBAR=false
      ;;
    *)
      echo "❌ Unknown option: $1"
      usage
      ;;
  esac
  shift
done

# โฟลเดอร์ feature
BASE_DIR="./lib/feature/${FEATURE_NAME}"
mkdir -p "$BASE_DIR/blocs" "$BASE_DIR/models" "$BASE_DIR/pages" "$BASE_DIR/widgets"

# สร้างไฟล์เพจ
PAGE_FILE="$BASE_DIR/pages/${FEATURE_NAME}_page.dart"
cat > "$PAGE_FILE" <<EOF
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:$PROJECT_PKG/shared/styles/p_colors.dart';
EOF

# เพิ่ม import สำหรับ AppBar ถ้ามี
if [ "$INCLUDE_APPBAR" = true ]; then
  echo "import 'package:$PROJECT_PKG/shared/widgets/appbar/appbar_custom.dart';" >> "$PAGE_FILE"
fi

# เพิ่ม import สำหรับ BottomBar ถ้ามี
if [ "$INCLUDE_BOTTOMBAR" = true ]; then
  echo "import 'package:$PROJECT_PKG/shared/widgets/appbar/bottombar_custom.dart';" >> "$PAGE_FILE"
fi

# เพิ่มส่วนที่เหลือของไฟล์เพจ
cat >> "$PAGE_FILE" <<EOF

@RoutePage()
class ${CLASS_NAME}Page extends StatelessWidget {
  const ${CLASS_NAME}Page({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRouteName = context.routeData.name;
    return Scaffold(
EOF

# เพิ่ม BottomBar ถ้ามี
if [ "$INCLUDE_BOTTOMBAR" = true ]; then
  cat >> "$PAGE_FILE" <<EOF
      bottomNavigationBar: BottomBarCustom(currentRouteName: currentRouteName),
EOF
fi

# เพิ่ม AppBar ถ้ามี
if [ "$INCLUDE_APPBAR" = true ]; then
  cat >> "$PAGE_FILE" <<EOF
      appBar: AppBarCustom(currentRouteName: currentRouteName),
EOF
fi

# ปิด Scaffold
cat >> "$PAGE_FILE" <<EOF
      backgroundColor: PColor.backgroundColor,
      body: Container(child: const Center(child: Text('$FEATURE_NAME'))),
    );
  }
}
EOF

echo "✅ Created page: $PAGE_FILE"

# -----------------------------
# อัปเดต router.dart
# -----------------------------
ROUTER_FILE="./lib/router/router.dart"   # ปรับ path นี้ให้ตรงโปรเจกต์คุณ

if [ ! -f "$ROUTER_FILE" ]; then
  echo "❌ Router file not found at $ROUTER_FILE"
  exit 1
fi

# 1) แทรก import (เฉพาะถ้ายังไม่มี)
IMPORT_LINE="import 'package:${PROJECT_PKG}/feature/${FEATURE_NAME}/pages/${FEATURE_NAME}_page.dart';"
if ! grep -Fxq "$IMPORT_LINE" "$ROUTER_FILE"; then
  # แทรกหลังบรรทัด import สุดท้าย (macOS ใช้ sed -i '')
  last_import_line=$(grep -n "^import " "$ROUTER_FILE" | tail -n1 | cut -d: -f1)
  if [ -n "$last_import_line" ]; then
    # แทรกบรรทัดใหม่ถัดจาก import สุดท้าย
    sed -i '' "$((last_import_line)) a\\
$IMPORT_LINE
" "$ROUTER_FILE"
    echo "➕ Added import to router.dart"
  else
    # ถ้าไม่มี import เลย ให้แทรกบนสุด
    sed -i '' "1s;^;${IMPORT_LINE}\n;" "$ROUTER_FILE"
    echo "➕ Added first import to router.dart"
  fi
else
  echo "ℹ️ Import already exists in router.dart"
fi

ROUTE_SNIPPET="        CustomRoute(
          page: ${CLASS_NAME}Route.page,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),"

if ! grep -q "page: ${CLASS_NAME}Route.page" "$ROUTER_FILE"; then
  # ใช้ awk แทน sed เพื่อความง่าย cross-platform
  awk -v route="$ROUTE_SNIPPET" '
    /List<AutoRoute> get routes => \[/ { print; next }
    /\];/ && !done { print route; done=1 }
    { print }
  ' "$ROUTER_FILE" > "${ROUTER_FILE}.tmp" && mv "${ROUTER_FILE}.tmp" "$ROUTER_FILE"

  echo "➕ Added route entry to router.dart"
else
  echo "ℹ️ Route entry already exists"
fi

rm -rf "${ROUTER_FILE}.tmp"

# สร้างไฟล์ gen
fvm dart run build_runner build -d

echo "✅ Feature '$FEATURE_NAME' wired into router.dart and generated routes."