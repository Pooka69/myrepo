# Podman Registry Authentication Fix

This repository contains a solution to fix the common issue where **Podman keeps logging you out of container registries** after system reboots or user logouts.

## The Problem

Podman stores registry authentication credentials in `$XDG_RUNTIME_DIR/containers/auth.json` by default. This directory is typically:
- Cleaned up when you log out of your system
- Temporary and not persisted across reboots
- Different for each session

This causes you to lose your registry credentials and need to run `podman login` repeatedly.

## The Solution

Configure Podman to store credentials in a **persistent location** using the `REGISTRY_AUTH_FILE` environment variable.

## Quick Start

### Automatic Setup (Recommended)

Run the setup script to automatically configure persistent authentication:

```bash
chmod +x setup-podman-auth.sh
./setup-podman-auth.sh
```

Then reload your shell configuration:

```bash
source ~/.bashrc  # or ~/.zshrc, depending on your shell
```

### Manual Setup

If you prefer to set things up manually:

1. Create a persistent directory for credentials:
   ```bash
   mkdir -p ~/.config/containers
   ```

2. Add this line to your `~/.bashrc` (or `~/.zshrc` for zsh users):
   ```bash
   export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"
   ```

3. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

4. If you have existing credentials, copy them:
   ```bash
   cp $XDG_RUNTIME_DIR/containers/auth.json ~/.config/containers/auth.json
   chmod 600 ~/.config/containers/auth.json
   ```

## Verification

After setup, verify that the environment variable is set correctly:

```bash
echo $REGISTRY_AUTH_FILE
```

Expected output: `/home/yourusername/.config/containers/auth.json`

## Usage

After configuring the persistent location, use podman login as normal:

```bash
podman login registry.example.com
```

Your credentials will now persist across:
- System reboots
- User logouts/logins
- Terminal sessions

## Logging into Common Registries

### Docker Hub
```bash
podman login docker.io
```

### Red Hat Registry
```bash
podman login registry.redhat.io
```

### GitHub Container Registry
```bash
podman login ghcr.io
```

### Quay.io
```bash
podman login quay.io
```

## Troubleshooting

### Still getting logged out?

1. Verify the environment variable is set:
   ```bash
   echo $REGISTRY_AUTH_FILE
   ```

2. Check if the auth file exists and has correct permissions:
   ```bash
   ls -la ~/.config/containers/auth.json
   ```
   Should show permissions: `-rw-------` (600)

3. Verify credentials are stored:
   ```bash
   cat ~/.config/containers/auth.json
   ```
   Should show JSON with your registry credentials (base64 encoded)

### Permission Issues

If you get permission errors, ensure the auth file has correct ownership and permissions:

```bash
chmod 600 ~/.config/containers/auth.json
chown $USER:$USER ~/.config/containers/auth.json
```

### Multiple Auth Files

If you use both Docker and Podman, they can share the same auth file:
```bash
export REGISTRY_AUTH_FILE="$HOME/.docker/config.json"
```

Or create a symbolic link:
```bash
ln -s ~/.docker/config.json ~/.config/containers/auth.json
```

## How It Works

By default, Podman uses these locations for storing credentials (in order of precedence):

1. `$REGISTRY_AUTH_FILE` (if set) - **Our solution uses this**
2. `$XDG_RUNTIME_DIR/containers/auth.json` (default, ephemeral)
3. `$HOME/.docker/config.json` (Docker fallback)

Setting `REGISTRY_AUTH_FILE` to a persistent location in your home directory ensures credentials survive across sessions.

## Additional Resources

- [Podman Login Documentation](https://docs.podman.io/en/latest/markdown/podman-login.1.html)
- [Podman Configuration Files](https://docs.podman.io/en/latest/markdown/podman-login.1.html#files)
- [Container Authentication](https://github.com/containers/image/blob/main/docs/containers-auth.json.5.md)

## Contributing

If you have improvements or found this helpful, feel free to open an issue or pull request!

## License

This solution is provided as-is for public use.
