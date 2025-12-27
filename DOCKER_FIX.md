# Docker Permission Fix Guide

## Issue: Permission Denied on Docker Socket

If you're getting `permission denied while trying to connect to the Docker daemon socket`, here are the solutions:

### Solution 1: Ensure Docker Service is Running

```bash
# Check Docker service status
sudo systemctl status docker

# If not running, start it
sudo systemctl start docker
sudo systemctl enable docker  # Enable on boot
```

### Solution 2: Add User to Docker Group (if not already done)

```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# IMPORTANT: You must log out and log back in (or restart your terminal session)
# for the group change to take effect!

# Verify after logging back in
groups  # Should show 'docker' in the list
```

### Solution 3: Refresh Group Membership (Without Logging Out)

If you don't want to log out, you can use `newgrp`:

```bash
# Start a new shell with updated groups
newgrp docker

# Now try docker commands in this new shell
docker ps
```

### Solution 4: Check Socket Permissions

```bash
# Check socket permissions
ls -l /var/run/docker.sock

# Should show something like:
# srw-rw---- 1 root docker 0 [date] /var/run/docker.sock

# If permissions are wrong, fix them (rarely needed)
sudo chmod 666 /var/run/docker.sock  # Temporary fix
# OR better:
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
```

### Quick Test

After fixing, test with:

```bash
docker ps
docker-compose --version
```

If these work without `sudo`, you're all set!

### Common Issues

**Issue**: "Command 'docker' not found"
- **Fix**: Docker is not installed. Install with: `sudo pacman -S docker docker-compose`

**Issue**: "Cannot connect to Docker daemon"
- **Fix**: Docker service is not running. Start with: `sudo systemctl start docker`

**Issue**: "Permission denied" even after adding to docker group
- **Fix**: You must **log out and log back in** for group membership to take effect, or use `newgrp docker`

