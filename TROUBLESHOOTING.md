# Troubleshooting Guide: Podman Registry Authentication

## Common Issues and Solutions

### Issue 1: Still Getting Logged Out After Setup

**Symptoms:**
- Ran setup script successfully
- Still need to login after reboot

**Solution:**
```bash
# 1. Check if the environment variable is set
echo $REGISTRY_AUTH_FILE
# Should output: /home/youruser/.config/containers/auth.json

# 2. If empty, reload your shell configuration
source ~/.bashrc  # or ~/.zshrc

# 3. Check if it's in your shell config file
grep REGISTRY_AUTH_FILE ~/.bashrc

# 4. If missing, run setup again
./setup-podman-auth.sh
```

### Issue 2: Permission Denied When Accessing Auth File

**Symptoms:**
- Error: "permission denied" when podman tries to read auth.json

**Solution:**
```bash
# Fix file permissions
chmod 600 ~/.config/containers/auth.json

# Fix ownership
chown $USER:$USER ~/.config/containers/auth.json

# Verify
ls -la ~/.config/containers/auth.json
# Should show: -rw------- (600)
```

### Issue 3: Auth File Not Found

**Symptoms:**
- Error: "auth file not found"
- REGISTRY_AUTH_FILE points to non-existent file

**Solution:**
```bash
# Create the directory if it doesn't exist
mkdir -p ~/.config/containers

# Create an empty auth file
echo '{"auths":{}}' > ~/.config/containers/auth.json
chmod 600 ~/.config/containers/auth.json

# Now login to your registries
podman login docker.io
```

### Issue 4: Setup Script Didn't Add to Shell Config

**Symptoms:**
- Script ran but ~/.bashrc wasn't updated

**Solution:**
```bash
# Manually add the export to your shell config
echo '' >> ~/.bashrc
echo '# Podman registry authentication - use persistent location' >> ~/.bashrc
echo 'export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"' >> ~/.bashrc

# For zsh users, use ~/.zshrc instead:
echo '' >> ~/.zshrc
echo '# Podman registry authentication - use persistent location' >> ~/.zshrc
echo 'export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"' >> ~/.zshrc

# Reload
source ~/.bashrc  # or source ~/.zshrc
```

### Issue 5: Using Both Docker and Podman

**Symptoms:**
- Have credentials in Docker, want to share with Podman
- Or vice versa

**Solution Option 1 - Share Docker's auth file:**
```bash
# Point Podman to Docker's auth file
echo 'export REGISTRY_AUTH_FILE="$HOME/.docker/config.json"' >> ~/.bashrc
source ~/.bashrc
```

**Solution Option 2 - Copy credentials:**
```bash
# Copy Docker credentials to Podman location
cp ~/.docker/config.json ~/.config/containers/auth.json
chmod 600 ~/.config/containers/auth.json
```

**Solution Option 3 - Symbolic link:**
```bash
# Create a symlink (both tools will share the same file)
ln -s ~/.docker/config.json ~/.config/containers/auth.json
```

### Issue 6: Credentials Work in One Terminal But Not Another

**Symptoms:**
- Logged in one terminal session
- New terminal doesn't have credentials

**Solution:**
```bash
# Each terminal needs the environment variable set
# Make sure your shell config file has the export:
grep REGISTRY_AUTH_FILE ~/.bashrc

# If missing, add it:
echo 'export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"' >> ~/.bashrc

# For existing terminals, source the config:
source ~/.bashrc

# Or close and open a new terminal
```

### Issue 7: Podman Desktop Not Using Persistent Location

**Symptoms:**
- Podman CLI works fine
- Podman Desktop still logs out

**Solution:**
```bash
# Podman Desktop should respect REGISTRY_AUTH_FILE
# Ensure it's set system-wide, not just in shell

# For systemd systems, add to ~/.profile:
echo 'export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"' >> ~/.profile

# Or set it in Podman Desktop's environment
# Check Podman Desktop documentation for environment variables
```

### Issue 8: Invalid JSON in Auth File

**Symptoms:**
- Error: "invalid character" or "cannot unmarshal"
- Podman can't read the auth file

**Solution:**
```bash
# Backup the corrupted file
cp ~/.config/containers/auth.json ~/.config/containers/auth.json.corrupted

# Create a fresh auth file
echo '{"auths":{}}' > ~/.config/containers/auth.json
chmod 600 ~/.config/containers/auth.json

# Re-login to your registries
podman login docker.io
podman login registry.redhat.io
```

### Issue 9: XDG_RUNTIME_DIR Not Set

**Symptoms:**
- Script can't find runtime directory
- Warnings about XDG_RUNTIME_DIR

**Solution:**
```bash
# This is okay - it means you don't have ephemeral credentials to migrate
# Just continue with the setup

# The persistent location will still work
./setup-podman-auth.sh

# Verify it's set up correctly
echo $REGISTRY_AUTH_FILE
```

### Issue 10: Multiple Auth Files Exist

**Symptoms:**
- Credentials in multiple locations
- Confused about which one is being used

**Solution:**
```bash
# Check which file Podman is using
podman system info | grep -i auth

# List all possible auth file locations
ls -la ~/.config/containers/auth.json
ls -la ~/.docker/config.json
ls -la $XDG_RUNTIME_DIR/containers/auth.json 2>/dev/null

# Consolidate to one location
# Copy all credentials to persistent location
# (Manual merge may be needed if conflicts exist)

# Then ensure REGISTRY_AUTH_FILE points to the right one
echo $REGISTRY_AUTH_FILE
```

### Issue 11: Script Fails with "Permission Denied"

**Symptoms:**
- Can't run setup-podman-auth.sh
- Permission denied error

**Solution:**
```bash
# Make the script executable
chmod +x setup-podman-auth.sh

# Run it again
./setup-podman-auth.sh
```

### Issue 12: Credentials Lost After System Update

**Symptoms:**
- Had working setup
- After OS update, credentials gone again

**Solution:**
```bash
# Check if REGISTRY_AUTH_FILE is still set
echo $REGISTRY_AUTH_FILE

# Check if the auth file still exists
ls -la ~/.config/containers/auth.json

# If file is gone, restore from backup
cp ~/.config/containers/auth.json.backup ~/.config/containers/auth.json

# If no backup, re-login to registries
podman login docker.io
```

### Issue 13: Using Podman in Containers

**Symptoms:**
- Running podman inside a container
- Credentials not accessible

**Solution:**
```bash
# Mount the auth file into the container
podman run -v ~/.config/containers/auth.json:/auth.json:ro \
  -e REGISTRY_AUTH_FILE=/auth.json \
  your-image

# Or mount the entire directory
podman run -v ~/.config/containers:/root/.config/containers:ro \
  your-image
```

### Issue 14: SELinux Issues

**Symptoms:**
- Running on SELinux-enabled system (RHEL, Fedora, CentOS)
- Permission denied despite correct file permissions

**Solution:**
```bash
# Check SELinux context
ls -Z ~/.config/containers/auth.json

# Fix SELinux context if needed
restorecon -Rv ~/.config/containers/

# Or temporarily disable SELinux to test (not recommended for production)
sudo setenforce 0
# Test if it works
# Re-enable SELinux
sudo setenforce 1
```

### Issue 15: Network Issues Preventing Login

**Symptoms:**
- "connection refused" or "timeout"
- Can't reach registry

**Solution:**
```bash
# Test network connectivity
ping registry.redhat.io
curl -I https://registry.redhat.io

# Check proxy settings if behind corporate firewall
echo $HTTP_PROXY
echo $HTTPS_PROXY

# Set proxy for podman if needed
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# Then try login again
podman login registry.redhat.io
```

## Diagnostic Commands

Run these to gather information for troubleshooting:

```bash
# 1. Check Podman version
podman --version

# 2. Check Podman system info
podman system info

# 3. Check environment variables
env | grep -i registry
env | grep -i xdg

# 4. Check auth file location being used
podman system info | grep -i auth

# 5. Check file permissions
ls -la ~/.config/containers/auth.json
ls -la ~/.docker/config.json

# 6. Check shell configuration
grep -n REGISTRY_AUTH_FILE ~/.bashrc ~/.zshrc ~/.profile 2>/dev/null

# 7. Test if registry is reachable
curl -I https://registry.redhat.io/v2/

# 8. Check for podman processes
ps aux | grep podman

# 9. Check podman storage
podman system df
```

## Getting Help

If you're still experiencing issues after trying these solutions:

1. **Gather diagnostic information:**
   Run the diagnostic commands listed above and save the output:
   ```bash
   podman --version > podman-diagnostics.txt
   podman system info >> podman-diagnostics.txt
   env | grep -i registry >> podman-diagnostics.txt
   ls -la ~/.config/containers/ >> podman-diagnostics.txt
   ```

2. **Check Podman logs:**
   ```bash
   journalctl --user -u podman
   ```

3. **Enable debug logging:**
   ```bash
   podman --log-level=debug login docker.io
   ```

4. **Search existing issues:**
   - Check [Podman GitHub issues](https://github.com/containers/podman/issues)
   - Check this repository's issues

5. **Open a new issue:**
   - Include the output from diagnostic commands
   - Include your OS and Podman version
   - Include relevant error messages

## Prevention Tips

1. **Backup your auth file regularly:**
   ```bash
   cp ~/.config/containers/auth.json ~/.config/containers/auth.json.backup-$(date +%Y%m%d)
   ```

2. **Use version control for scripts (but not auth files!):**
   ```bash
   git add setup-podman-auth.sh
   git commit -m "Update setup script"
   # Never: git add auth.json  # This is blocked by .gitignore
   ```

3. **Test after system updates:**
   ```bash
   # After any system update, verify:
   echo $REGISTRY_AUTH_FILE
   podman login --get-login docker.io
   ```

4. **Document your setup:**
   Keep notes on which registries you use and any special configuration.

5. **Use strong, unique credentials:**
   Use different passwords or tokens for each registry.
