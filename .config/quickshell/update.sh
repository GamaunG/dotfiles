#!/bin/bash

SOURCE_DIR="/usr/share/quickshell/dms"
TARGET_DIR="$HOME/.config/quickshell/dms"
PATCHES_DIR="$HOME/.config/quickshell/dmspatches"

COPY_PATHS=(
	"VERSION"
	"Services/NiriService.qml"
	"Modules/DankBar/DankBarWindow.qml"
	"Modules/DankBar/Widgets/WorkspaceSwitcher.qml"
	"Modules/Lock/LockScreenContent.qml"
)

[[ ! -d "$SOURCE_DIR" ]] && echo "Error: Source directory $SOURCE_DIR not found." >&2 && exit 1

[[ -e "$TARGET_DIR" ]] && rm -rf "$TARGET_DIR"

find "$SOURCE_DIR" -type f | while read -r srcFile; do
	relPath="${srcFile#"$SOURCE_DIR/"}"
	targetFile="$TARGET_DIR/$relPath"
	targetDir=$(dirname "$targetFile")

	mkdir -p "$targetDir"

	if [[ " ${COPY_PATHS[*]} " == *" $relPath "* ]]; then
		cp "$srcFile" "$targetFile"
	else
		ln -s "$srcFile" "$targetFile"
	fi
done

for patchFile in "$PATCHES_DIR"/*.patch; do
	patch -d "$TARGET_DIR" -p0 --no-backup-if-mismatch < "$patchFile"
done
