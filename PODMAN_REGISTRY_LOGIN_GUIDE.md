# How to Keep Your Registries Logged In on Podman

This guide explains how to maintain persistent authentication to container registries when using Podman.

## Quick Start

To log in to a container registry and keep the credentials stored:

```bash
podman login <registry-url>
```

For example:
```bash
podman login docker.io
podman login registry.redhat.io
podman login ghcr.io
```

You'll be prompted for your username and password. Podman will store these credentials securely for future use.

## How Podman Stores Registry Credentials

Podman stores registry authentication credentials in an `auth.json` file. The location depends on whether you're running as root or a regular user:

### For Regular Users (Rootless Mode)
```
$XDG_RUNTIME_DIR/containers/auth.json
```
Or if `XDG_RUNTIME_DIR` is not set:
```
$HOME/.config/containers/auth.json
```

### For Root Users
```
/run/containers/0/auth.json
```
Or:
```
/root/.config/containers/auth.json
```

## Keeping Your Login Persistent

Once you've logged in using `podman login`, your credentials are automatically saved and will persist across:
- System reboots
- Terminal sessions
- Podman container/image operations

### Verifying Your Login Status

To check which registries you're currently logged into:

```bash
podman login --get-login <registry-url>
```

For example:
```bash
podman login --get-login docker.io
```

## Using Credentials Files

### Manually Specifying Auth File Location

You can specify a custom authentication file location:

```bash
podman login --authfile /path/to/custom/auth.json <registry-url>
```

Then use it for operations:
```bash
podman pull --authfile /path/to/custom/auth.json <image>
```

### Sharing Auth Files Across Systems

You can copy your `auth.json` file to other systems to share credentials:

```bash
# On source system
cp ~/.config/containers/auth.json ~/auth-backup.json

# Transfer to target system and restore
mkdir -p ~/.config/containers
cp auth-backup.json ~/.config/containers/auth.json
chmod 600 ~/.config/containers/auth.json
```

## Environment Variables

You can also use environment variables for authentication:

```bash
export REGISTRY_AUTH_FILE=/path/to/auth.json
```

This tells Podman where to find/store authentication credentials.

## Troubleshooting

### Login Not Persisting

If your login doesn't persist, check:

1. **Verify the auth file exists:**
   ```bash
   cat ~/.config/containers/auth.json
   ```

2. **Check file permissions:**
   ```bash
   chmod 600 ~/.config/containers/auth.json
   ```

3. **Ensure the directory exists:**
   ```bash
   mkdir -p ~/.config/containers
   ```

### "unauthorized: authentication required" Error

If you see this error despite logging in:

1. **Re-login to the registry:**
   ```bash
   podman login <registry-url>
   ```

2. **Check if credentials expired:**
   Some registries have token expiration. Log in again to refresh.

3. **Verify registry URL:**
   Make sure you're using the correct registry URL (e.g., `docker.io` not `index.docker.io`)

### Permission Denied Errors

If you get permission errors:

1. **Check if running in rootless mode:**
   ```bash
   podman info --format '{{.Host.Security.Rootless}}'
   ```

2. **Ensure proper ownership:**
   ```bash
   chown $(id -u):$(id -g) ~/.config/containers/auth.json
   ```

## Best Practices

1. **Use rootless Podman when possible** - Keeps credentials in your user directory
2. **Protect your auth.json file** - Keep permissions set to `600` (readable/writable by owner only)
3. **Use credential helpers** - Consider using credential helpers like `podman-credential-helper` for enhanced security
4. **Logout when done** - On shared systems, logout when finished:
   ```bash
   podman logout <registry-url>
   ```
5. **Use tokens instead of passwords** - When available, use personal access tokens or service account tokens
6. **Regular credential rotation** - Periodically update your registry credentials

## Advanced: Using Credential Helpers

For enhanced security, you can use credential helpers that integrate with system keychains:

```bash
# Install credential helper (example for pass)
sudo apt-get install pass  # or your package manager

# Initialize pass (required for first-time setup)
gpg --generate-key  # If you don't have a GPG key
pass init <your-gpg-key-id>

# Ensure the credential helper executable is in PATH
# It should be named podman-credential-pass (or similar for other helpers)

# Configure in containers.conf
mkdir -p ~/.config/containers
echo '[engine]' >> ~/.config/containers/containers.conf
echo 'credential_helpers = ["pass"]' >> ~/.config/containers/containers.conf
```

**Note:** Credential helpers require:
- The helper executable must be in your PATH with the naming convention `podman-credential-<helper>`
- Proper initialization of the credential store (e.g., `pass init` for pass)
- The helper must support the credential helper protocol

## Multiple Registry Authentication

You can be logged into multiple registries simultaneously:

```bash
podman login docker.io
podman login quay.io
podman login ghcr.io
podman login registry.gitlab.com
```

All credentials are stored in the same `auth.json` file.

## Logout from Registries

To logout from a specific registry:

```bash
podman logout <registry-url>
```

To logout from all registries:

```bash
podman logout --all
```

## Summary

- Use `podman login <registry>` to authenticate and store credentials
- Credentials are stored in `~/.config/containers/auth.json` for regular users
- Logins persist automatically across sessions and reboots
- Protect your `auth.json` file with proper permissions (600)
- Use `podman login --get-login <registry>` to verify login status
- Consider using credential helpers for enhanced security

For more information, consult the official Podman documentation:
```bash
man podman-login
```
