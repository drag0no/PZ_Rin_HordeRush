#!/bin/bash

MODS_DIR="Contents/mods"

echo "Scanning for mods in $MODS_DIR..."

for MOD_PATH in "$MODS_DIR"/*/; do
    [ -d "$MOD_PATH" ] || continue

    echo "> Processing: $MOD_NAME"

    MOD_NAME=$(basename "$MOD_PATH")
    TARGET_DIR="$MODS_DIR/$MOD_NAME"

    if [ ! -f "$TARGET_DIR/mod.info" ]; then
        echo "  * Skipping '$MOD_NAME' - No mod.info found."
        continue
    fi

    mkdir -p "$TARGET_DIR/42"
    mkdir -p "$TARGET_DIR/common"

    if [ -d "$TARGET_DIR/media" ]; then
        cp -r "$TARGET_DIR/media" "$TARGET_DIR/common/"
    fi

    cp "$TARGET_DIR/mod.info" "$TARGET_DIR/42/"
    if [ -f "$TARGET_DIR/poster.png" ]; then
        cp "$TARGET_DIR/poster.png" "$TARGET_DIR/42/"
    fi

    echo "  * Successfully restructured '$MOD_NAME'."
done

echo "Processing complete!"