# Quick Reference Card: Podman Registry Authentication Fix

## Problem
Podman logs you out of registries after logout/reboot because credentials are stored in a temporary directory (`$XDG_RUNTIME_DIR`).

## Solution
Use a persistent location for authentication credentials.

## One-Time Setup

```bash
# Run the setup script
chmod +x setup-podman-auth.sh
./setup-podman-auth.sh

# Reload your shell
source ~/.bashrc  # or ~/.zshrc
```

## Alternative: Environment Variable Only

Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"
```

## Verification

```bash
# Check the variable is set
echo $REGISTRY_AUTH_FILE

# Should output: /home/yourusername/.config/containers/auth.json
```

## After Setup

Just use podman login normally:

```bash
podman login docker.io
podman login registry.redhat.io
podman login ghcr.io
```

Your credentials will now persist permanently!

## Common Registries

| Registry | Command |
|----------|---------|
| Docker Hub | `podman login docker.io` |
| Red Hat | `podman login registry.redhat.io` |
| GitHub | `podman login ghcr.io` |
| Quay.io | `podman login quay.io` |
| GitLab | `podman login registry.gitlab.com` |

## Troubleshooting

### Still losing credentials?
```bash
# Verify environment variable is set
echo $REGISTRY_AUTH_FILE

# Check file exists and has correct permissions
ls -la ~/.config/containers/auth.json

# Should show: -rw------- (permissions 600)
```

### Fix permissions if needed
```bash
chmod 600 ~/.config/containers/auth.json
```

### Migrate existing credentials
```bash
cp $XDG_RUNTIME_DIR/containers/auth.json ~/.config/containers/auth.json
```

## Why This Works

Podman searches for credentials in this order:
1. **$REGISTRY_AUTH_FILE** ← We set this to a persistent location
2. $XDG_RUNTIME_DIR/containers/auth.json (ephemeral, gets deleted)
3. $HOME/.docker/config.json (Docker compatibility)

By setting #1, we bypass the ephemeral location and use a persistent one instead.
