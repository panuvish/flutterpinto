#!/bin/bash

# กำหนด path ของ directory
LOCALS_DIR="./lib/i18n/locals"
I18N_FILE="./lib/i18n/i18n.dart"

# ขั้นตอน 1: Generate localization files ด้วย flutter gen-l10n
echo "Step 1: Generating localization files..."
for dir in "$LOCALS_DIR"/*; do
    if [ -d "$dir" ]; then
        page_name=$(basename "$dir")
        
        temp_name=$(echo "$page_name" | tr '[:upper:]' '[:lower:]')
        class_name=$(echo "$temp_name" | awk -F'_' '{for(i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' OFS='')
        
        output_file="${page_name}_localizations.dart"
        class_name="${class_name}Localizations"
        
        echo "Generating localization for $page_name $output_file..."
        flutter gen-l10n \
            --arb-dir "$LOCALS_DIR/$page_name" \
            --template-arb-file en.arb \
            --output-localization-file "$output_file" \
            --output-class "$class_name"
    fi
done

# ขั้นตอน 2: Generate i18n.dart
echo -e "\nStep 2: Generating i18n.dart..."

# เริ่มต้นสร้างเนื้อหาไฟล์ i18n.dart
cat > "$I18N_FILE" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
EOF

# เพิ่ม import
for dir in "$LOCALS_DIR"/*; do
    if [ -d "$dir" ]; then
        page_name=$(basename "$dir")
        echo "import 'package:mobile_app_standard/i18n/locals/${page_name}/${page_name}_localizations.dart';" >> "$I18N_FILE"
    fi
done

# เพิ่มส่วนที่เหลือของไฟล์
cat >> "$I18N_FILE" << 'EOF'

class I18n {
  static final all = [
    const Locale('en'),
    const Locale('th'),
  ];
}

class AppLocalizations {
  final BuildContext context;

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
EOF

# เพิ่ม delegate
for dir in "$LOCALS_DIR"/*; do
    if [ -d "$dir" ]; then
        page_name=$(basename "$dir")
        temp_name=$(echo "$page_name" | tr '[:upper:]' '[:lower:]')
        class_name=$(echo "$temp_name" | awk -F'_' '{for(i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' OFS='')
        class_name="${class_name}Localizations"
        echo "        ${class_name}.delegate," >> "$I18N_FILE"
    fi
done

# ปิด delegates และเพิ่ม constructor
cat >> "$I18N_FILE" << 'EOF'
      ];

  AppLocalizations(this.context);
EOF

# เพิ่ม getter
for dir in "$LOCALS_DIR"/*; do
    if [ -d "$dir" ]; then
        page_name=$(basename "$dir")
        temp_name=$(echo "$page_name" | tr '[:upper:]' '[:lower:]')
        class_name=$(echo "$temp_name" | awk -F'_' '{for(i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' OFS='')
        class_name="${class_name}Localizations"
        
        getter_name=$(echo "$page_name" | awk -F'_' '{for(i=1; i<=NF; i++) if(i==1) $i=tolower($i); else $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' OFS='')
        
        echo "  // Get ${class_name}" >> "$I18N_FILE"
        echo "  ${class_name} get ${getter_name} => ${class_name}.of(context)!;" >> "$I18N_FILE"
        echo "" >> "$I18N_FILE"
    fi
done

# ปิด class
echo "}" >> "$I18N_FILE"

echo "Done! Generated localization files and $I18N_FILE"