---
name: file-transfer
description: This skill should be used when the user asks to "copy files to a server", "upload to remote host", "download from server", "sync files to production", "transfer build artifacts", "rsync to staging", "scp a file", "push static assets to server", or needs to move files between their local machine and a remote host.
version: 1.0.0
---

# Remote File Transfer

Patterns for copying and syncing files with remote hosts using `scp` and `rsync`.

## SCP — Simple Copies

Best for single files or small directories when you don't need incremental sync.

```bash
# Upload a file
scp ./config.json user@host:/etc/app/config.json

# Upload a directory (recursive)
scp -r ./dist/ user@host:/var/www/app/

# Download a file from remote
scp user@host:/var/log/app/app.log ./app.log

# Non-standard port
scp -P 2222 ./file.txt user@host:/tmp/
```

## rsync — Incremental Sync

Prefer `rsync` for deployments and directory syncs — it only transfers changed files.

```bash
# Sync local directory to remote (dry-run first to preview)
rsync --dry-run -avz ./dist/ user@host:/var/www/app/

# Actually sync
rsync -avz --progress ./dist/ user@host:/var/www/app/

# Delete remote files that no longer exist locally (mirror mode)
rsync -avz --delete ./dist/ user@host:/var/www/app/

# Exclude files
rsync -avz --exclude='.env' --exclude='node_modules/' ./app/ user@host:/srv/app/

# Pull from remote to local
rsync -avz user@host:/var/backups/db/ ./backups/

# Non-standard SSH port
rsync -avz -e "ssh -p 2222" ./dist/ user@host:/var/www/app/
```

## Common rsync Flags

| Flag | Meaning |
|------|---------|
| `-a` | Archive mode: preserves permissions, timestamps, symlinks |
| `-v` | Verbose: show files being transferred |
| `-z` | Compress during transfer (good for slow connections) |
| `--progress` | Show per-file progress |
| `--delete` | Delete remote files not in source (use carefully!) |
| `--dry-run` / `-n` | Preview what would be transferred without doing it |
| `--exclude` | Skip matching files/dirs |
| `--checksum` | Compare by checksum rather than timestamp+size |

## Deployment Pattern

A safe deploy sequence using rsync:

```bash
# 1. Dry-run to verify what will change
rsync --dry-run -avz --delete ./dist/ user@host:/var/www/app/

# 2. Execute the sync
rsync -avz --delete ./dist/ user@host:/var/www/app/

# 3. Reload the web server to pick up new files
ssh user@host "sudo systemctl reload nginx"
```

## Permissions and Ownership

After transferring files, you may need to fix ownership:
```bash
# Fix ownership after rsync (run on remote)
ssh user@host "sudo chown -R www-data:www-data /var/www/app/"
ssh user@host "sudo chmod -R 755 /var/www/app/"
```

## Large File Transfers

For large files or unreliable connections, use `rsync` with resume support:
```bash
rsync -avz --partial --progress large-file.tar.gz user@host:/tmp/
# --partial keeps partially-transferred files so a retry picks up where it left off
```
