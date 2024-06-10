#!/bin/bash

# Check if the necessary tools are installed
if ! command -v magick &> /dev/null || ! command -v cwebp &> /dev/null
then
    echo "imagemagick or webp tools are not installed. Please install them using Homebrew."
    exit 1
fi

# Directory containing PNG files
DIRECTORY="$1"

if [ -z "$DIRECTORY" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Convert all PNG images in the directory
for img in "$DIRECTORY"/*.png; do
    if [ -f "$img" ]; then
        # Convert to JPG and WebP
        jpg_file="${img%.png}.jpg"
        webp_file="${img%.png}.webp"

        magick "$img" "$jpg_file"
        cwebp -q 80 "$img" -o "$webp_file"

        # Get file sizes
        png_size=$(stat -f%z "$img")
        jpg_size=$(stat -f%z "$jpg_file")
        webp_size=$(stat -f%z "$webp_file")

        echo "File: $img"
        echo "PNG size: $png_size bytes"
        echo "JPG size: $jpg_size bytes"
        echo "WebP size: $webp_size bytes"

        # Determine the smallest file
        smallest_size=$png_size
        smallest_file="$img"
        decision="png"
        
        if [ "$jpg_size" -lt "$smallest_size" ]; then
            smallest_size=$jpg_size
            smallest_file=$jpg_file
            decision="jpg"
        fi

        if [ "$webp_size" -lt "$smallest_size" ]; then
            smallest_size=$webp_size
            smallest_file=$webp_file
            decision="webp"
        fi

        echo "Chosen format: $decision"
        echo

        # Keep the smallest file with correct extension
        if [ "$smallest_file" != "$img" ]; then
            new_file="${img%.png}.$decision"
            mv "$smallest_file" "$new_file"
        fi

        # Remove other formats
        [ -f "$jpg_file" ] && [ "$jpg_file" != "$smallest_file" ] && rm "$jpg_file"
        [ -f "$webp_file" ] && [ "$webp_file" != "$smallest_file" ] && rm "$webp_file"
    fi
done

# Ask user if they want to delete the original PNG files
read -r -p "Do you want to delete the original PNG files? (y/N): " choice

if [ "$choice" = "y" ]; then
    for img in "$DIRECTORY"/*.png; do
        if [ -f "$img" ]; then
            rm "$img"
            echo "Deleted: $img"
        fi
    done
    echo "Original PNG files have been deleted."
else
    echo "Original PNG files have been kept."
fi

echo "Conversion complete."
