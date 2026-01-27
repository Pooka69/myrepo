# MyRepo

This repository contains programs and utilities.

## Uninstalling Programs

To uninstall a program from the terminal, use the `uninstall.sh` script:

```bash
./uninstall.sh <program_name>
```

### Example

To uninstall the `mealie` program:

```bash
./uninstall.sh mealie
```

### Usage

1. Make sure the script is executable:
   ```bash
   chmod +x uninstall.sh
   ```

2. Run the script with the program name you want to uninstall:
   ```bash
   ./uninstall.sh <program_name>
   ```

The script will:
- Check if the program exists in the current directory
- Remove the program if found
- Display a success message
- Show an error if the program is not found
