# Nginx - Setup and Usage Guide

This stack runs Nginx with:

- a service-catalog home page;
- proxy route discovery from `configs/sites-enabled`;
- automatic `services.json` generation on startup;
- service routing by `location` (for example, Portainer at `/portainer/`).

## 1. Structure

- `docker-compose.yml`: main Nginx stack.
- `.env`: stack environment variables.
- `configs/nginx.conf`: global Nginx configuration.
- `configs/sites-enabled/index.conf`: main server block (port 80, index page, and error pages).
- `configs/sites-enabled/*.locations`: service-specific `location` blocks.
- `configs/html/index/index.html`: catalog UI.
- `configs/html/index/generate-services-catalog.sh`: auto-generates `services.json`.

## 2. Prerequisites

- Docker and Docker Compose installed.
- Docker network configured as defined in `.env` (`NETWORK_NAME`) when needed to reach upstream services outside this stack.

## 3. Basic Configuration

Edit `.env`:

- `APP_PORT`: published host port (current default: `80`).
- `IMAGE_NAME` and `IMAGE_VERSION`: Nginx image/tag.
- `CONTAINER_NAME`: fixed container name.
- `NETWORK_NAME`: Docker network name used by the stack.

## 4. Start, Stop, and Monitor

From this project directory (`tools/docker/applications/nginx`):

```bash
docker compose up -d --build
```

```bash
docker compose logs -f app
```

```bash
docker compose down
```

Main page URL:

- `http://<your-host-or-ip>:<APP_PORT>/`

## 5. How Automatic Catalog Generation Works

On startup, compose runs:

```sh
sh /usr/share/nginx/html/index/generate-services-catalog.sh /etc/nginx/sites-enabled /usr/share/nginx/html/index/services.json
```

The script:

1. scans `.conf` and `.locations` files in `/etc/nginx/sites-enabled`;
2. detects `location` blocks containing `proxy_pass`;
3. generates `services.json` consumed by the frontend;
4. builds cards with proxy route and inferred direct host/port access.

## 6. Add a New Service to the Catalog

### Step 1: Create the location file

Example `configs/sites-enabled/grafana.locations`:

```nginx
location = /grafana {
    return 301 /grafana/;
}

location /grafana/ {
    set $grafana_upstream http://grafana:3000;
    rewrite ^/grafana/(.*)$ /$1 break;
    proxy_pass $grafana_upstream;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Step 2: Include it in the main server

In `configs/sites-enabled/index.conf`, add:

```nginx
include /etc/nginx/sites-enabled/grafana.locations;
```

### Step 3: Recreate or restart

```bash
docker compose up -d --build
```

The new service card will be displayed automatically on the home page.

## 7. Troubleshooting

### Error: `Permission denied` when creating `services.json`

Typical message:

```text
/usr/share/nginx/html/index/generate-services-catalog.sh: ... Permission denied
```

Common cause:

- container running as non-root (`user: ${APP_UID}:${APP_GID}`) without write permission on `./configs/html` bind mount.

Fix options:

1. Keep `user:` disabled (currently commented in compose).
2. Keep `user:` enabled and adjust host ownership/permissions to match `APP_UID/APP_GID`.
3. Robust alternative: generate to `/tmp/services.json` and expose it through `location = /services.json` in Nginx.

### Nginx startup permission error (chown/client_temp)

Typical message:

```text
chown("/var/cache/nginx/client_temp", 101) failed (1: Operation not permitted)
```

Common cause:

- hardening with `cap_drop: ALL` without minimum capabilities.

Recommended compose adjustment (already supported):

- `cap_add: CHOWN, SETUID, SETGID, NET_BIND_SERVICE`.

### Validate Nginx configuration

```bash
docker compose exec app nginx -t
```

### Reload without restarting the container

```bash
docker compose exec app nginx -s reload
```

## 8. Best Practices

- Avoid competing `server` blocks on the same host/port unless required.
- Prefer a single main server in `index.conf` and include per-service `.locations` files.
- Always run `nginx -t` before reload.
- In production, pin image versions and review compose security settings.
