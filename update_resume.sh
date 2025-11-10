#!/bin/bash

# Script to update resume on GitHub Pages
# Usage: ./update_resume.sh [optional_filepath]
# If no filepath is provided, uses the most recently added file from ~/Downloads

# Configuration - Update these for your own setup
GITHUB_USERNAME="lavonda-li"
RESUME_FILENAME="Lavonda_Li_Stanford_Resume.pdf"

# Get the directory where this script is actually located (follow symlinks)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
TARGET_FILE="$SCRIPT_DIR/files/$RESUME_FILENAME"

# Check if a filepath argument was provided
if [ -n "$1" ]; then
    SOURCE_FILE="$1"
else
    # Find the most recently added file in ~/Downloads
    # Using -type f to only get files, not directories
    # Only match files starting with Lavonda_Li_Stanford_Resume and ending with .pdf
    SOURCE_FILE=$(ls -t ~/Downloads/Lavonda_Li_Stanford_Resume*.pdf 2>/dev/null | head -n 1)
    
    if [ -z "$SOURCE_FILE" ]; then
        echo "Error: No files found in ~/Downloads matching pattern 'Lavonda_Li_Stanford_Resume*.pdf'"
        exit 1
    fi
    
    echo "Using... $(basename "$SOURCE_FILE")"
fi

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: File not found: $SOURCE_FILE"
    exit 1
fi

# Check if the file is a PDF
if [[ ! "$SOURCE_FILE" =~ \.pdf$ ]]; then
    echo "Error: File is not a PDF: $SOURCE_FILE"
    exit 1
fi

# Copy the file to the target location
cp "$SOURCE_FILE" "$TARGET_FILE"

if [ $? -eq 0 ]; then
    echo "✓ Successfully updated resume"
else
    echo "Error: Failed to copy file"
    exit 1
fi

# Git operations
echo ""

# Change to the repository directory to run git commands
cd "$SCRIPT_DIR"

git add "$TARGET_FILE"

# Check if there are actually changes to commit
if git diff --cached --quiet; then
    echo "No changes detected - resume is already up to date"
else
    echo "Committing and pushing changes..."
    
    git commit -m "Update resume"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to commit changes"
        exit 1
    fi
    
    git push origin master
    
    if [ $? -eq 0 ]; then
        echo "✓ Changes pushed to remote repository"
    else
        echo "Error: Failed to push to remote"
        exit 1
    fi
fi

# Open the resume URL in browser
open "https://${GITHUB_USERNAME}.github.io/files/$RESUME_FILENAME"

