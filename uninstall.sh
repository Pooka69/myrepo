#!/bin/bash
# Uninstall script for removing programs

# Check if a program name is provided
if [ $# -eq 0 ]; then
    echo "Usage: ./uninstall.sh <program_name>"
    echo "Example: ./uninstall.sh mealie"
    exit 1
fi

PROGRAM_NAME=$1

# Check if the program exists in the current directory
if [ -e "$PROGRAM_NAME" ]; then
    echo "Uninstalling $PROGRAM_NAME..."
    if rm -f "$PROGRAM_NAME"; then
        echo "Successfully uninstalled $PROGRAM_NAME"
        exit 0
    else
        echo "Error: Failed to uninstall $PROGRAM_NAME. Check permissions."
        exit 1
    fi
else
    echo "Error: Program '$PROGRAM_NAME' not found in the current directory"
    exit 1
fi
