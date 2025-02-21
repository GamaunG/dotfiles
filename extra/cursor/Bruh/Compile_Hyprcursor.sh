#!/bin/bash
if [[ ! $(command -v jq) ]]; then
	echo "jq is not installed"
	exit 1
fi

[[ ! -d "./cursors_scalable" && ! -d "./index.theme" ]] && exit
rm -rf ./hyprcursors
cp -r ./cursors_scalable/ ./hyprcursors && cd ./hyprcursors || exit

dirs=$(find . -maxdepth 1 -type d -printf '%P\n')
links=$(find . -maxdepth 1 -type l -printf '%P\n')

echo "Converting metadata..."
for dir in $dirs; do
	[[ ! -d "$dir" || -L "$dir" ]] && continue
	[[ -f "$dir/metadata.json" ]] && source="$dir/metadata.json" || continue
	target="$dir/meta.hl"
	size=$(jq -r '.[].nominal_size' "$source" | head -n1)
	hotspot_x=$(jq -r '.[].hotspot_x' "$source" | head -n1)
	hotspot_y=$(jq -r '.[].hotspot_y' "$source" | head -n1)
	hotspot_x=$(awk "BEGIN {printf \"%.3f\", $hotspot_x/$size}")
	hotspot_y=$(awk "BEGIN {printf \"%.3f\", $hotspot_y/$size}")
	{
		echo "resize_algorithm = bilinear" #available: bilinear, nearest, none.
		echo ""
		echo "hotspot_x = $hotspot_x"
		echo "hotspot_y = $hotspot_y"
		echo ""
		jq -r '.[] | "define_size = \(.nominal_size), \(.filename), \(.delay)"' "$source" | sed 's/, null//'
		echo ""
	} >"$target"
done

for link in $links; do
	# [[ ${#link} == "32" ]] && continue
	target="$link/meta.hl"
	echo "define_override = $link" >>"$target"
done

for link in $links; do
	rm "$link"
done
echo "Done"
cd ..

echo "Compiling..."

name=$(grep -oP '^Name=\K.*' ./index.theme)
if [[ ! -f "./manifest.hl" ]]; then
	comment=$(grep -oP '^Comment=\K.*' ./index.theme)
	cat <<EOF >./manifest.hl
name = $name
description = $comment
version = 0.1
cursors_directory = hyprcursors
EOF
fi

hyprcursor-util --create .

if [[ -d "../theme_$name" ]]; then
	rm -rf ./hyprcursors
	mv "../theme_$name/hyprcursors" .
	rm -rf "../theme_$name"
fi
