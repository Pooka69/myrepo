#!/bin/bash
# Helper script to check and migrate podman credentials
# This can be run automatically on login or manually when needed

PERSISTENT_AUTH_FILE="${HOME}/.config/containers/auth.json"
RUNTIME_AUTH_FILE="${XDG_RUNTIME_DIR}/containers/auth.json"

# Ensure the persistent directory exists
mkdir -p "${HOME}/.config/containers"

# If runtime auth file exists and is newer than persistent file, sync it
if [ -n "${XDG_RUNTIME_DIR}" ] && [ -f "${RUNTIME_AUTH_FILE}" ]; then
    if [ ! -f "${PERSISTENT_AUTH_FILE}" ] || [ "${RUNTIME_AUTH_FILE}" -nt "${PERSISTENT_AUTH_FILE}" ]; then
        cp "${RUNTIME_AUTH_FILE}" "${PERSISTENT_AUTH_FILE}"
        chmod 600 "${PERSISTENT_AUTH_FILE}"
    fi
fi

# Ensure REGISTRY_AUTH_FILE points to persistent location
if [ "${REGISTRY_AUTH_FILE}" != "${PERSISTENT_AUTH_FILE}" ]; then
    export REGISTRY_AUTH_FILE="${PERSISTENT_AUTH_FILE}"
fi
