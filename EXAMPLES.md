# Usage Examples for Podman Registry Authentication Fix

## Example 1: First-Time Setup

```bash
# Clone the repository
git clone https://github.com/Pooka69/myrepo.git
cd myrepo

# Run the setup script
chmod +x setup-podman-auth.sh
./setup-podman-auth.sh

# Reload your shell
source ~/.bashrc

# Verify the setup
echo $REGISTRY_AUTH_FILE
# Output: /home/youruser/.config/containers/auth.json
```

## Example 2: Login to Multiple Registries

After running the setup, log into your registries:

```bash
# Docker Hub
podman login docker.io
# Enter username and password when prompted

# Red Hat Registry
podman login registry.redhat.io
# Enter Red Hat credentials

# GitHub Container Registry
podman login ghcr.io
# Use GitHub username and personal access token

# Your own private registry
podman login registry.mycompany.com
```

All these credentials will now persist across reboots!

## Example 3: Verifying Credentials are Saved

```bash
# Check the auth file exists
ls -la ~/.config/containers/auth.json

# View stored registries (credentials are base64 encoded)
cat ~/.config/containers/auth.json | jq .

# Example output:
# {
#   "auths": {
#     "docker.io": {
#       "auth": "dXNlcm5hbWU6cGFzc3dvcmQ="
#     },
#     "registry.redhat.io": {
#       "auth": "dXNlcjp0b2tlbg=="
#     }
#   }
# }
```

## Example 4: Using Podman After Setup

```bash
# Pull an image (will use saved credentials)
podman pull docker.io/library/nginx:latest

# Push to your registry (will use saved credentials)
podman tag myimage:latest registry.mycompany.com/myimage:latest
podman push registry.mycompany.com/myimage:latest

# No need to login again - credentials persist!
```

## Example 5: Migrating from Docker

If you're switching from Docker and want to reuse Docker credentials:

```bash
# Option 1: Copy Docker credentials
cp ~/.docker/config.json ~/.config/containers/auth.json

# Option 2: Use Docker's auth file directly
echo 'export REGISTRY_AUTH_FILE="$HOME/.docker/config.json"' >> ~/.bashrc
source ~/.bashrc
```

## Example 6: Running the Sync Script Manually

If you've logged in using the old method and want to migrate:

```bash
# First, login using the old way (credentials go to runtime dir)
unset REGISTRY_AUTH_FILE
podman login docker.io

# Now sync them to the persistent location
./sync-podman-auth.sh

# Set the persistent location for future use
source ~/.bashrc
```

## Example 7: Automation in Scripts

Use the persistent location in your CI/CD scripts:

```bash
#!/bin/bash
# ci-build.sh

export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"

# Now podman commands will use the persistent credentials
podman build -t myapp:latest .
podman push registry.mycompany.com/myapp:latest
```

## Example 8: Multiple Users on Same System

Each user should run the setup independently:

```bash
# User 1
su - user1
cd /path/to/myrepo
./setup-podman-auth.sh
podman login docker.io

# User 2
su - user2
cd /path/to/myrepo
./setup-podman-auth.sh
podman login docker.io
```

Each user's credentials are stored in their own home directory.

## Example 9: Checking Login Status

```bash
# Before the fix: Check current auth file location
podman system info | grep auth

# After the fix: Verify persistent location is used
podman system info | grep auth
# Should show: /home/youruser/.config/containers/auth.json

# List logged-in registries
podman login --get-login docker.io
# Output: yourusername
```

## Example 10: Troubleshooting - Re-running Setup

If something goes wrong, you can safely re-run the setup:

```bash
# Re-run setup (safe to run multiple times)
./setup-podman-auth.sh

# The script will:
# - Skip if directory already exists
# - Skip if shell config already has the variable
# - Update credentials if newer ones exist
```

## Example 11: Systemd Integration (Advanced)

For automatic sync on login, create a systemd user service:

```bash
# Create service file
mkdir -p ~/.config/systemd/user/
cat > ~/.config/systemd/user/podman-auth-sync.service << 'EOF'
[Unit]
Description=Sync Podman authentication credentials

[Service]
Type=oneshot
ExecStart=/path/to/myrepo/sync-podman-auth.sh

[Install]
WantedBy=default.target
EOF

# Enable and start
systemctl --user daemon-reload
systemctl --user enable podman-auth-sync.service
systemctl --user start podman-auth-sync.service
```

## Example 12: Backing Up Credentials

```bash
# Create a backup
cp ~/.config/containers/auth.json ~/.config/containers/auth.json.backup

# Restore from backup
cp ~/.config/containers/auth.json.backup ~/.config/containers/auth.json
chmod 600 ~/.config/containers/auth.json
```

## Example 13: Removing Credentials

```bash
# Logout from a specific registry
podman logout docker.io

# Logout from all registries
podman logout --all

# Or manually delete the auth file
rm ~/.config/containers/auth.json
```

## Example 14: Using with Podman Desktop

The fix works with both CLI and Podman Desktop:

```bash
# Run the setup
./setup-podman-auth.sh

# Start Podman Desktop
podman-desktop

# Login via Podman Desktop UI
# Credentials will be saved to the persistent location
# And will persist across Podman Desktop restarts
```

## Example 15: Environment-Specific Credentials

For different environments:

```bash
# Development
export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth-dev.json"
podman login dev-registry.company.com

# Production (separate file)
export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth-prod.json"
podman login prod-registry.company.com

# Switch between them in your scripts
export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth-${ENV}.json"
```

## Tips

1. **Always run setup-podman-auth.sh first** - This configures everything correctly
2. **Use the sync script** if you have existing credentials you want to preserve
3. **Check the auth file permissions** - Should be 600 (only you can read/write)
4. **Never commit auth.json to git** - The .gitignore is set up to prevent this
5. **Reuse credentials** - The same auth.json can be used by both Docker and Podman
