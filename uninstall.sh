#!/bin/bash

# Terminal Uninstall Script
# This script allows uninstalling programs via command line

set -e

# Display usage information
usage() {
    echo "Usage: $0 [PROGRAM_NAME]"
    echo ""
    echo "Uninstall a program from the system"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List installed programs"
    echo ""
    echo "Examples:"
    echo "  $0 mealie      Uninstall the 'mealie' program"
    echo "  $0 --list      List all installed programs"
    exit 0
}

# List installed programs (from current directory)
list_programs() {
    local should_exit="${1:-true}"
    echo "Installed programs:"
    echo ""
    
    # List files that represent "programs" (exclude specific system files)
    local excluded_files=("uninstall.sh" "hello.txt" "README.md")
    for file in *; do
        if [ -f "$file" ]; then
            local skip=false
            for excluded in "${excluded_files[@]}"; do
                if [ "$file" = "$excluded" ]; then
                    skip=true
                    break
                fi
            done
            if [ "$skip" = false ]; then
                echo "  - $file"
            fi
        fi
    done
    
    if [ "$should_exit" = "true" ]; then
        exit 0
    fi
}

# Uninstall a program
uninstall_program() {
    local program_name="$1"
    
    if [ -z "$program_name" ]; then
        echo "Error: Program name is required"
        usage
    fi
    
    # Check if program exists
    if [ ! -f "$program_name" ]; then
        echo "Error: Program '$program_name' not found"
        echo ""
        echo "Available programs:"
        list_programs false
        exit 1
    fi
    
    # Confirm uninstallation (with 30 second timeout)
    echo "Are you sure you want to uninstall '$program_name'? (y/n)"
    if read -t 30 -r confirmation; then
        if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ]; then
            rm -f "$program_name"
            echo "Successfully uninstalled '$program_name'"
            exit 0
        else
            echo "Uninstallation cancelled"
            exit 1
        fi
    else
        echo ""
        echo "Timeout: No response received. Uninstallation cancelled"
        exit 1
    fi
}

# Main script logic
main() {
    # Check for help flag
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage
    fi
    
    # Check for list flag
    if [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
        list_programs
    fi
    
    # If no arguments, show usage
    if [ $# -eq 0 ]; then
        usage
    fi
    
    # Uninstall the specified program
    uninstall_program "$1"
}

main "$@"
