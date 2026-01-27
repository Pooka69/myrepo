# Terminal Uninstall

A simple command-line tool for uninstalling programs.

## Usage

### Show Help
```bash
./uninstall.sh --help
```

### List Installed Programs
```bash
./uninstall.sh --list
```

### Uninstall a Program
```bash
./uninstall.sh [PROGRAM_NAME]
```

For example, to uninstall the `mealie` program:
```bash
./uninstall.sh mealie
```

The script will ask for confirmation before removing the program.

## Features

- List all installed programs
- Uninstall programs with confirmation prompt
- User-friendly help documentation
- Error handling for non-existent programs
