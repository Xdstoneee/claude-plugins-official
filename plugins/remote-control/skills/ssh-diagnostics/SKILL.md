---
name: ssh-diagnostics
description: This skill should be used when the user says "SSH isn't working", "can't connect to server", "connection refused", "permission denied (publickey)", "host key verification failed", "SSH timeout", "connection timed out", "no route to host", "SSH hangs", or asks why SSH is failing. Provides a structured diagnostic flow to identify and fix SSH connection problems.
version: 1.0.0
---

# SSH Diagnostics

Step-by-step approach to diagnosing and resolving SSH connection failures.

## Diagnostic Ladder

Work through these checks in order — stop when you find the problem.

### Step 1 — DNS Resolution
Can the hostname be resolved?
```bash
dig +short <hostname>
# or
nslookup <hostname>
```
If this fails: the hostname is wrong, DNS is misconfigured, or the host doesn't exist. Check spelling, VPN connectivity, or use the IP address directly.

### Step 2 — Network Reachability
Can you reach the host at the SSH port?
```bash
nc -zv <host> <port>          # quick port check
# or
telnet <host> <port>           # alternative
# or
curl -v telnet://<host>:<port> # if nc/telnet not available
```
If this fails: a firewall, security group, or NAT rule is blocking the port. Check cloud provider security groups, UFW/iptables on the host, or corporate firewalls.

### Step 3 — SSH Handshake
Does SSH get past the handshake?
```bash
ssh -vvv -o ConnectTimeout=10 <user@host>
```
Look for:
- `Connection established` → got through the network
- `Authentications that can continue` → what auth methods the server accepts
- `Permission denied (publickey)` → key not accepted (see Step 4)
- `Host key verification failed` → see "Known Hosts Issues" below

### Step 4 — Key Authentication
Is the right key being offered?
```bash
ssh -vvv <user@host> 2>&1 | grep -E "Offering|identity|Trying"
```
Common fixes:
- Key not loaded: `ssh-add ~/.ssh/id_rsa` (or the correct key)
- Wrong key: `ssh -i ~/.ssh/specific_key <user@host>`
- Key permissions too open: `chmod 600 ~/.ssh/id_rsa`
- Key not in `authorized_keys` on server: add public key to `~/.ssh/authorized_keys` on the remote

### Step 5 — Server-Side Auth Logs
If you have another way onto the server (console access, cloud web shell):
```bash
# On the remote host:
sudo tail -50 /var/log/auth.log         # Debian/Ubuntu
sudo tail -50 /var/log/secure           # RHEL/CentOS
sudo journalctl -u sshd -n 50
```

## Known Hosts Issues

**`Host key verification failed`** — the server's key changed (reinstall, IP reuse, MITM risk):
```bash
# Remove the stale entry:
ssh-keygen -R <hostname>
ssh-keygen -R <ip-address>
# Then reconnect — verify the new fingerprint is expected
```

**`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`** on a server you just rebuilt:
This is expected after a fresh OS install. Remove and re-accept the key as above, but always verify the fingerprint through a trusted channel (cloud console, etc.) before accepting.

## Common Quick Fixes

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `Connection refused` | SSH not running / wrong port | Check `sshd` is running; verify port |
| `Permission denied (publickey)` | Key mismatch | `ssh-add` the right key or use `-i` |
| `Connection timed out` | Firewall blocking | Open port 22 (or custom) in security group |
| `Host key verification failed` | Key changed | `ssh-keygen -R <host>` |
| Hangs after banner | TCP connection works, auth stalls | Check `~/.ssh/config` multiplexing or GSSAPI |
| Works as root, not as user | `authorized_keys` permissions | `chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys` on remote |
