#!/bin/bash

# Loop through each directory in the current directory
for dir in */ ; do
  # Remove the trailing slash from the directory name
  dir=${dir%/}
  # Compress the directory with zero compression using zip
  zip -r -0 "${dir}.zip" "$dir"
done
