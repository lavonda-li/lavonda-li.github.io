#!/bin/bash

# Shared helper: update_file <keyword> <target_filename> <optional_source>
# Finds the most recently added PDF in ~/Downloads matching *<keyword>*.pdf,
# copies it to files/<target_filename>, commits, and pushes.

GITHUB_USERNAME="lavonda-li"

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

update_file() {
    local keyword="$1"
    local target_filename="$2"
    local source_arg="$3"
    local target_file="$SCRIPT_DIR/files/$target_filename"
    local source_file

    if [ -n "$source_arg" ]; then
        source_file="$source_arg"
    else
        source_file=$(ls -t ~/Downloads/*"$keyword"*.pdf 2>/dev/null | head -n 1)
        if [ -z "$source_file" ]; then
            echo "Error: No files found in ~/Downloads matching pattern '*${keyword}*.pdf'"
            exit 1
        fi
        echo "$(basename "$source_file")"
    fi

    if [ ! -f "$source_file" ]; then
        echo "Error: File not found: $source_file"
        exit 1
    fi

    if [[ ! "$source_file" =~ \.pdf$ ]]; then
        echo "Error: File is not a PDF: $source_file"
        exit 1
    fi

    cp "$source_file" "$target_file" || { echo "Error: Failed to copy file"; exit 1; }

    cd "$SCRIPT_DIR"
    git add "$target_file"

    if git diff --cached --quiet; then
        echo "Up to date"
    else
        git commit -m "Update $keyword" || { echo "Error: commit failed"; exit 1; }
        git push origin master || { echo "Error: push failed"; exit 1; }
        echo "✓ Pushed"
    fi

    open "https://${GITHUB_USERNAME}.github.io/files/$target_filename"
    open -a Preview "$target_file"
}
