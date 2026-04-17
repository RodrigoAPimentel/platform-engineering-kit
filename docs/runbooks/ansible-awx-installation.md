# 🚀 Ansible AWX Installation & Operation

Complete runbook for installing, configuring, and operating Ansible AWX across multiple Linux distributions.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Installation](#quick-installation)
3. [Installation by Distribution](#installation-by-distribution)
4. [Post-Installation Setup](#post-installation-setup)
5. [Accessing AWX](#accessing-awx)
6. [Common Operations](#common-operations)
7. [Troubleshooting](#troubleshooting)
8. [Backup & Recovery](#backup--recovery)

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended |
| ----------- | ------- | ----------- |
| CPU Cores   | 2       | 4+          |
| RAM         | 4 GB    | 8 GB+       |
| Disk Space  | 20 GB   | 50 GB+      |
| Docker      | 20.10+  | 24.0+       |

### Supported Distributions

- ✅ **CentOS 7** (with yum)
- ✅ **CentOS 8+** (with dnf)
- ✅ **RHEL 8+** (with dnf)
- ✅ **Ubuntu 20.04 LTS+** (with apt)
- ✅ **Debian 11+** (with apt)

### Required Tools

Ensure these are installed on the target host:

```bash
# Check required tools
command -v git && echo "✓ Git installed"
command -v docker && echo "✓ Docker installed"
command -v ansible && echo "✓ Ansible installed"
command -v python3 && echo "✓ Python 3 installed"
```

---

## Quick Installation

### Default Installation (Recommended)

```bash
# Clone or download the install script
sudo /path/to/scripts/install/install-ansible-awx.sh

# Output will show:
# - AWX admin username and password
# - Default access URL: http://localhost
```

### Custom Configuration Examples

#### Example 1: Install specific AWX version with custom admin user

```bash
sudo /path/to/scripts/install/install-ansible-awx.sh \
  --awx-version 21.11.0 \
  --admin-user administrator \
  --admin-password MySecurePassword123!
```

#### Example 2: Install with Docker Compose v2 and auto-reboot

```bash
sudo /path/to/scripts/install/install-ansible-awx.sh \
  --awx-version 17.1.0 \
  --docker-compose 2.20.0 \
  --reboot
```

#### Example 3: Skip system updates (for pre-configured systems)

```bash
sudo /path/to/scripts/install/install-ansible-awx.sh \
  --skip-system-update \
  --awx-version 21.11.0
```

---

## Installation by Distribution

### CentOS 7 / RHEL 7

```bash
# Prerequisites already handled by install script
# But verify these are available:
sudo yum install -y git gcc gcc-c++ nodejs python3-pip

# Run installation
sudo bash scripts/install/install-ansible-awx.sh

# Expected duration: 10-15 minutes
```

**Notes:**

- Uses `yum` as package manager
- Docker Compose falls back to standalone binary if plugin unavailable
- Service name for OpenSSH is `sshd`

### CentOS 8+ / RHEL 8+

```bash
# Installation with DNF
sudo bash scripts/install/install-ansible-awx.sh

# Or with specific version
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 21.11.0

# Expected duration: 8-12 minutes
```

**Notes:**

- Uses `dnf` (recommended package manager)
- EPEL repository automatically configured
- Faster than CentOS 7 due to better dependency resolution

### Ubuntu 20.04 LTS / Ubuntu 22.04 LTS

```bash
# Update system first (optional with flag)
sudo bash scripts/install/install-ansible-awx.sh \
  --awx-version 17.1.0

# Or skip system update if already done
sudo bash scripts/install/install-ansible-awx.sh \
  --skip-system-update

# Expected duration: 8-12 minutes
```

**Notes:**

- Uses `apt` as package manager
- Docker repository automatically added
- Service name for OpenSSH is `ssh`

### Debian 11+

```bash
# Similar to Ubuntu installation
sudo bash scripts/install/install-ansible-awx.sh \
  --admin-user admin \
  --admin-password SecurePass@2024

# Expected duration: 10-15 minutes
```

---

## Post-Installation Setup

### 1. Verify Installation

```bash
# Check Docker containers are running
docker ps | grep awx

# Expected output should show:
# - awx-postgres
# - awx-redis
# - awx-web
# - awx-task

# Check AWX service status
sudo systemctl status docker
docker logs -f awx-web  # Monitor startup logs
```

### 2. Wait for AWX to be Ready

```bash
# AWX takes 2-5 minutes to fully initialize
# Monitor progress
docker logs -f awx-web | grep -i "ready\|listening\|started"

# Or check HTTP response
curl -s http://localhost -o /dev/null -w "%{http_code}\n"
# Expected: 200 when ready, 502 during startup
```

### 3. Initial Login

```bash
# Default credentials (unless changed during installation)
Username: root
Password: toor

# Access via browser:
# http://<your-host-ip>
# or
# http://localhost (if accessing locally)
```

### 4. Secure Initial Setup

1. **Change default admin password:**
   - Login → Settings (⚙️ icon) → Users → root → Edit
   - Change "Password" field
   - Save

2. **Create additional admin users:**
   - Settings → Users → Create User
   - Set role to "System Administrator"

3. **Configure SMTP for notifications:**
   - Settings → Email → Configure
   - Enter your SMTP server details

4. **Setup SSH Key Authentication:**
   - Settings → Credentials → Create New
   - Type: Machine
   - Add SSH private keys for automation

---

## Accessing AWX

### Local Access (Same Machine)

```bash
# Direct browser access
firefox http://localhost
# or
http://127.0.0.1
```

### Remote Access

#### Option 1: Direct HTTP (Development Only)

```bash
# Open port in firewall (if using firewalld)
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload

# Access from remote machine
curl http://<server-ip>
# or in browser
http://192.168.1.100
```

⚠️ **Warning:** Not recommended for production. HTTP traffic is unencrypted.

#### Option 2: SSH Tunnel (Secure)

From your local machine:

```bash
# Create SSH tunnel to AWX server
ssh -L 8080:localhost:80 user@<awx-server-ip>

# In browser, access:
http://localhost:8080
```

#### Option 3: NGINX Reverse Proxy with SSL (Recommended for Production)

See [NGINX SSL Proxy Setup](#nginx-ssl-proxy-setup) section below.

### NGINX SSL Proxy Setup

If you need HTTPS access to AWX:

```bash
# Install NGINX
sudo apt-get install -y nginx  # Ubuntu/Debian
# or
sudo dnf install -y nginx      # CentOS 8+/RHEL

# Create NGINX config
sudo tee /etc/nginx/sites-available/awx > /dev/null <<'EOF'
upstream awx {
    server 127.0.0.1:80;
}

server {
    listen 443 ssl http2;
    server_name awx.example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://awx;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name awx.example.com;
    return 301 https://$server_name$request_uri;
}
EOF

# Enable and test
sudo nginx -t
sudo systemctl enable --now nginx
```

---

## Common Operations

### Start/Stop AWX

```bash
# Start AWX containers
docker-compose -f ~/.awx/awxcompose/docker-compose.yml up -d

# Stop AWX containers
docker-compose -f ~/.awx/awxcompose/docker-compose.yml down

# Restart specific service
docker restart awx-web
docker restart awx-task
```

### View Logs

```bash
# Real-time AWX web logs
docker logs -f awx-web

# Real-time task logs
docker logs -f awx-task

# Database logs
docker logs -f awx-postgres

# Last 100 lines
docker logs --tail 100 awx-web
```

### Upgrade AWX Version

```bash
# Create backup (see Backup section)
bash scripts/maintenance/backup-awx.sh

# Download and upgrade to new version
cd /tmp
wget https://github.com/ansible/awx/archive/21.11.0.zip
unzip 21.11.0.zip
cd awx-21.11.0/installer

# Run upgrade playbook
ansible-playbook -i inventory upgrade.yml
```

### Scale AWX Task Instances

Increase concurrent job execution by adding task workers:

```bash
# Edit AWX configuration
docker exec awx-web awx-manage shell

# Then in the shell:
# >>> from awx.main.models import Instance
# >>> Instance.objects.filter(role='execution').count()  # View current
# >>> exit()

# Or modify environment via docker-compose.yml
sudo vi ~/.awx/awxcompose/docker-compose.yml
# Find awx-task service and increase replicas
# then: docker-compose up -d
```

---

## Troubleshooting

### AWX Web Service Not Starting

```bash
# Check container logs
docker logs awx-web

# Common issues:
# 1. Port 80 already in use
sudo lsof -i :80
sudo netstat -tlnp | grep :80

# 2. Database connection failed
docker logs awx-postgres
# Ensure postgres is running and healthy

# 3. Restart all services
docker-compose -f ~/.awx/awxcompose/docker-compose.yml restart
```

### High Memory Usage

```bash
# Monitor resource usage
docker stats awx-web awx-task awx-postgres awx-redis

# If consuming too much memory:
# 1. Reduce concurrent jobs (see Common Operations)
# 2. Increase server RAM
# 3. Optimize playbooks to use less memory

# Check available memory
free -h
```

### Database Corruption

```bash
# Check PostgreSQL logs
docker logs awx-postgres | grep -i error

# If corrupted, rebuild database:
docker-compose -f ~/.awx/awxcompose/docker-compose.yml down
docker volume rm ~/.awx/awxcompose_postgres_data  # ⚠️ DELETES DATA

cd ~/.awx/awxcompose
docker-compose up -d awx-postgres
# Wait for database to initialize (2-3 minutes)
docker-compose up -d
```

### Cannot Access AWX Remotely

**Debug steps:**

```bash
# 1. Verify AWX is listening on port 80
sudo netstat -tlnp | grep :80
# Should show LISTEN on 0.0.0.0:80 or 127.0.0.1:80

# 2. If only on 127.0.0.1, edit docker-compose to expose
docker inspect awx-web | grep -A 5 "PortBindings"

# 3. Check firewall rules
sudo firewall-cmd --list-all  # CentOS/RHEL
sudo ufw status               # Ubuntu

# 4. Test connectivity
curl http://localhost         # From server
curl http://<server-ip>       # From another machine

# 5. Check NGINX reverse proxy (if used)
sudo nginx -t
sudo tails /var/log/nginx/error.log
```

### Authentication Failures

```bash
# Reset admin password via container
docker exec -it awx-web awx-manage changepassword admin

# Or access AWX API directly
curl -X POST http://localhost/api/v2/tokens/ \
  -H "Content-Type: application/json" \
  -d '{"username": "root", "password": "toor"}'

# If locked out completely, reset via container shell
docker exec -it awx-web bash
awx-manage shell
# >>> from awx.main.models import User
# >>> u = User.objects.get(username='root')
# >>> u.set_password('newpassword')
# >>> u.save()
# >>> exit()
```

---

## Backup & Recovery

### Create Backup

```bash
# Simple backup of database volume
docker exec awx-postgres pg_dump -U awx awx > /backup/awx-$(date +%Y%m%d).sql

# Or use provided maintenance script
bash scripts/maintenance/backup-awx.sh
```

### Full System Backup

```bash
# Backup everything
mkdir -p /backup/awx-full-$(date +%Y%m%d)

# Database
docker exec awx-postgres pg_dump -U awx awx > /backup/awx-full-$(date +%Y%m%d)/database.sql

# Configuration and volumes
docker-compose -f ~/.awx/awxcompose/docker-compose.yml exec postgres pg_dump -U awx awx | gzip > /backup/awx-full-$(date +%Y%m%d)/database.sql.gz

# Docker volumes (manual backup)
sudo tar -czf /backup/awx-full-$(date +%Y%m%d)/volumes.tar.gz ~/.awx/awxcompose/ 2>/dev/null || true
```

### Restore from Backup

```bash
# Stop AWX
docker-compose -f ~/.awx/awxcompose/docker-compose.yml down

# Restore database
docker exec -i awx-postgres psql -U awx awx < /backup/awx-20240101.sql

# Restart
docker-compose -f ~/.awx/awxcompose/docker-compose.yml up -d
```

---

## Security Best Practices

### 1. Change Default Credentials

```bash
# First action after installation
# UI: Settings → Users → root → Edit → Password
# Or CLI:
docker exec awx-web awx-manage changepassword root
```

### 2. Enable SSL/TLS

```bash
# Use NGINX reverse proxy (see section above)
# Or configure AWX directly for HTTPS:
docker-compose -f ~/.awx/awxcompose/docker-compose.yml down
# Edit docker-compose.yml to add SSL certs
# Restart containers
```

### 3. Restrict Network Access

```bash
# UFW (Ubuntu)
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# firewalld (CentOS/RHEL)
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --reload
```

### 4. Setup LDAP/AD Authentication

In AWX UI:

- Settings → Authentication → LDAP
- Configure LDAP server connection
- Map user attributes
- Test connection

### 5. Regular Backups

```bash
# Schedule daily backups
crontab -e
# Add: 0 2 * * * docker exec awx-postgres pg_dump -U awx awx | gzip > /backup/awx-$(date +\%Y\%m\%d).sql.gz
```

---

## References

- **Official AWX Documentation:** https://ansible.readthedocs.io/projects/awx/en/latest/
- **Docker Compose Docs:** https://docs.docker.com/compose/
- **Ansible Documentation:** https://docs.ansible.com/
- **GitHub AWX Repository:** https://github.com/ansible/awx
- **Community Forum:** https://www.ansible.com/community

---

## Support & Troubleshooting Resources

| Issue                | Resource                                                    |
| -------------------- | ----------------------------------------------------------- |
| Installation fails   | Check logs: `docker logs awx-web`                           |
| Performance problems | Review: [Common Operations](#common-operations)             |
| Database issues      | See: [Troubleshooting](#troubleshooting)                    |
| Backup/Recovery      | Refer: [Backup & Recovery](#backup--recovery)               |
| Security concerns    | Review: [Security Best Practices](#security-best-practices) |

---

**Last Updated:** April 17, 2026  
**AWX Versions Supported:** 17.1.0 - 21.11.0+
