#!/bin/bash
# Setup script to fix podman registry logout issue
# This script configures podman to use a persistent location for registry credentials

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Podman Registry Authentication Fix${NC}"
echo "===================================="
echo ""

# Define persistent auth file location
AUTH_DIR="${HOME}/.config/containers"
AUTH_FILE="${AUTH_DIR}/auth.json"

# Create directory if it doesn't exist
if [ ! -d "${AUTH_DIR}" ]; then
    echo -e "${YELLOW}Creating directory: ${AUTH_DIR}${NC}"
    mkdir -p "${AUTH_DIR}"
fi

# Check if auth.json already exists in runtime directory
RUNTIME_AUTH_FILE="${XDG_RUNTIME_DIR}/containers/auth.json"
if [ -n "${XDG_RUNTIME_DIR}" ] && [ -f "${RUNTIME_AUTH_FILE}" ]; then
    echo -e "${YELLOW}Found existing credentials in runtime directory${NC}"
    
    # Only copy if persistent file doesn't exist or is older
    if [ ! -f "${AUTH_FILE}" ] || [ "${RUNTIME_AUTH_FILE}" -nt "${AUTH_FILE}" ]; then
        echo "Copying credentials to persistent location..."
        cp "${RUNTIME_AUTH_FILE}" "${AUTH_FILE}"
        chmod 600 "${AUTH_FILE}"
        echo -e "${GREEN}✓ Credentials copied successfully${NC}"
    else
        echo "Persistent credentials are up to date"
    fi
fi

# Create or update shell configuration
SHELL_RC=""
if [ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ]; then
    SHELL_RC="${HOME}/.bashrc"
elif [ -n "${ZSH_VERSION}" ] && [ -f "${HOME}/.zshrc" ]; then
    SHELL_RC="${HOME}/.zshrc"
elif [ -f "${HOME}/.profile" ]; then
    SHELL_RC="${HOME}/.profile"
fi

ENV_EXPORT="export REGISTRY_AUTH_FILE=\"${AUTH_FILE}\""

if [ -n "${SHELL_RC}" ]; then
    # Check if the export already exists
    if grep -q "REGISTRY_AUTH_FILE" "${SHELL_RC}"; then
        echo -e "${YELLOW}REGISTRY_AUTH_FILE already configured in ${SHELL_RC}${NC}"
    else
        echo ""
        echo "Adding REGISTRY_AUTH_FILE to ${SHELL_RC}"
        echo "" >> "${SHELL_RC}"
        echo "# Podman registry authentication - use persistent location" >> "${SHELL_RC}"
        echo "${ENV_EXPORT}" >> "${SHELL_RC}"
        echo -e "${GREEN}✓ Configuration added to ${SHELL_RC}${NC}"
    fi
fi

# Set for current session
export REGISTRY_AUTH_FILE="${AUTH_FILE}"

echo ""
echo -e "${GREEN}Setup Complete!${NC}"
echo ""
echo "What was done:"
echo "  1. Created persistent directory: ${AUTH_DIR}"
if [ -n "${XDG_RUNTIME_DIR}" ] && [ -f "${XDG_RUNTIME_DIR}/containers/auth.json" ]; then
    echo "  2. Migrated existing credentials from runtime directory"
fi
if [ -n "${SHELL_RC}" ]; then
    echo "  3. Added REGISTRY_AUTH_FILE to ${SHELL_RC}"
fi
echo "  4. Set REGISTRY_AUTH_FILE for current session"
echo ""
echo "Next steps:"
echo "  - Reload your shell configuration: source ${SHELL_RC:-~/.bashrc}"
echo "  - Or start a new terminal session"
echo "  - Your podman registry logins will now persist across reboots"
echo ""
echo "To verify: echo \$REGISTRY_AUTH_FILE"
echo "Expected: ${AUTH_FILE}"
