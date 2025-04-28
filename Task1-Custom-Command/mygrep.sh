#!/bin/bash

# Show script usage
usage() {
    echo "Usage: $0 [options] search_string filename"
    echo "Options:"
    echo "  -n    Show line numbers"
    echo "  -v    Invert match (show non-matching lines)"
    echo "  --help  Show this help message"
}

# Handle --help
if [[ "$1" == "--help" ]]; then
    usage
    exit 0
fi

# Check for minimum arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Missing arguments."
    usage
    exit 1
fi

# Initialize option flags
show_line_numbers=false
invert_match=false

# Parse options with getopts
while getopts ":nv" opt; do
    case $opt in
        n) show_line_numbers=true ;;
        v) invert_match=true ;;
        \?) 
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1 ;;
    esac
done

# Remove parsed options from arguments
shift $((OPTIND -1))

# Assign search string and filename
search_string="$1"
file="$2"

# Validate search string and file
if [[ -z "$search_string" || -z "$file" ]]; then
    echo "Error: Missing search string or filename."
    usage
    exit 1
fi

# Check if file exists
if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Read file and search
line_number=0
cat "$file" | while read -r line; do
    ((line_number++))

    # Case-insensitive search with sed
    output=$(echo "$line" | sed -n "/$search_string/Ip")
    [[ -n "$output" ]] && matched=true || matched=false

    # Invert match if needed
    if $invert_match; then
        matched=$(! $matched && echo true || echo false)
    fi

    # Print matched line
    if $matched; then
        if $show_line_numbers; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done
