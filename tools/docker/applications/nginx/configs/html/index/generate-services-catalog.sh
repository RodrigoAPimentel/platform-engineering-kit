#!/bin/sh
set -eu

SITES_DIR="${1:-/etc/nginx/sites-enabled}"
OUT_FILE="${2:-/usr/share/nginx/html/index/services.json}"

TMP_RECORDS="$(mktemp)"
TMP_UNIQ="$(mktemp)"
trap 'rm -f "$TMP_RECORDS" "$TMP_UNIQ"' EXIT

extract_records() {
  awk -v src_file="$1" '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    BEGIN { inloc=0; depth=0; route=""; proxy=""; set_name=""; set_value="" }
    {
      line=$0
    }
    /^[ \t]*location[ \t]+/ {
      if (inloc == 0) {
        route=""
        proxy=""
        set_name=""
        set_value=""
        if (match($0, /location[ \t]+((=|\^~|~\*)[ \t]+|~[ \t]+)?([^ \t{]+)/)) {
          raw=substr($0, RSTART, RLENGTH)
          sub(/^[ \t]*location[ \t]+((=|\^~|~\*)[ \t]+|~[ \t]+)?/, "", raw)
          sub(/[ \t]*\{?$/, "", raw)
          route=trim(raw)
          if (route ~ /^\^\/nginx-exporter\//) {
            route="/nginx-exporter/"
          } else if (route ~ /^\^/) {
            sub(/^\^/, "", route)
          }
          inloc=1
          depth=0
        }
      }
    }

    inloc == 1 {
      open_count = gsub(/\{/, "{", line)
      close_count = gsub(/\}/, "}", line)

      if (match($0, /set[ \t]+\$[A-Za-z0-9_]+[ \t]+[^;]+;/)) {
        set_stmt=substr($0, RSTART, RLENGTH)
        sub(/^[ \t]*set[ \t]+\$/, "", set_stmt)
        split(set_stmt, parts, /[ \t]+/)
        set_name=parts[1]
        sub(/^[^ \t]+[ \t]+/, "", set_stmt)
        sub(/;$/, "", set_stmt)
        set_value=trim(set_stmt)
      }

      if (match($0, /proxy_pass[ \t]+[^;]+;/)) {
        proxy_stmt=substr($0, RSTART, RLENGTH)
        sub(/^[ \t]*proxy_pass[ \t]+/, "", proxy_stmt)
        sub(/;$/, "", proxy_stmt)
        proxy=trim(proxy_stmt)
      }

      depth += open_count
      depth -= close_count

      if (depth <= 0) {
        if (route ~ /^\// && route != "/" && route != "/404.html" && route != "/50x.html" && route !~ /unavailable/ && proxy != "") {
          if (proxy ~ /^\$/ && set_name != "" && proxy == "$" set_name) {
            proxy=set_value
          }
          print route "|" proxy "|" src_file
        }
        inloc=0
        depth=0
        route=""
        proxy=""
      }
    }
  ' "$1"
}

for conf in "$SITES_DIR"/*; do
  [ -f "$conf" ] || continue
  case "$conf" in
    *.conf|*.locations) extract_records "$conf" >> "$TMP_RECORDS" ;;
  esac
done

sort -u "$TMP_RECORDS" > "$TMP_UNIQ"

service_count=$(wc -l < "$TMP_UNIQ" | tr -d ' ')
generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

normalize_route() {
  route="$1"
  case "$route" in
    */) printf '%s' "$route" ;;
    *) printf '%s/' "$route" ;;
  esac
}

service_name_from_route() {
  route="$1"
  clean=$(printf '%s' "$route" | sed 's#^/*##; s#/*$##')
  if [ -z "$clean" ]; then
    printf 'Home'
    return
  fi
  printf '%s' "$clean" | awk -F'/' '{
    out=""
    for (i=1; i<=NF; i++) {
      p=$i
      if (length(p) == 0) continue
      gsub(/[-_]+/, " ", p)
      split(p, parts, /[[:space:]]+/)
      chunk=""
      for (j=1; j<=length(parts); j++) {
        if (length(parts[j]) == 0) continue
        part=parts[j]
        part=toupper(substr(part,1,1)) tolower(substr(part,2))
        chunk = chunk (chunk=="" ? "" : " ") part
      }
      p=chunk
      out = out (out=="" ? "" : " ") p
    }
    print out
  }'
}

second_location_route() {
  file="$1"
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    BEGIN { count=0 }
    /^[ \t]*location[ \t]+/ {
      if (match($0, /location[ \t]+((=|\^~|~\*)[ \t]+|~[ \t]+)?([^ \t{]+)/)) {
        raw=substr($0, RSTART, RLENGTH)
        sub(/^[ \t]*location[ \t]+((=|\^~|~\*)[ \t]+|~[ \t]+)?/, "", raw)
        sub(/[ \t]*\{?$/, "", raw)
        route=trim(raw)
        if (route ~ /^\^/) sub(/^\^/, "", route)
        count += 1
        if (count == 2) {
          if (route ~ /^\//) {
            if (route !~ /\/$/) route = route "/"
            print route
          }
          exit
        }
      }
    }
  ' "$file"
}

service_name_for_source() {
  source_file="$1"
  route="$2"

  case "$source_file" in
    *.locations)
      second_route=$(second_location_route "$source_file")
      if [ -n "$second_route" ]; then
        service_name_from_route "$second_route"
        return
      fi
      ;;
  esac

  service_name_from_route "$route"
}

icon_for_service() {
  s=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$s" in
    *alertmanager*) printf 'prometheus' ;;
    *portainer*|*docker*) printf 'docker' ;;
    *grafana*|*dashboard*) printf 'chart' ;;
    *prometheus*|*metrics*) printf 'pulse' ;;
    *nginx-exporter*|*exporter*) printf 'pulse' ;;
    *kibana*|*elastic*|*search*) printf 'search' ;;
    *jenkins*|*ci*|*pipeline*) printf 'automation' ;;
    *keycloak*|*auth*|*oauth*|*sso*) printf 'shield' ;;
    *postgres*|*mysql*|*mongo*|*redis*|*db*) printf 'database' ;;
    *rabbitmq*|*kafka*|*queue*|*broker*) printf 'stream' ;;
    *) printf 'app' ;;
  esac
}

slugify() {
  printf '%s' "$1" | sed 's#^/*##; s#/*$##; s#/#-#g'
}

printf '{\n' > "$OUT_FILE"
printf '  "generatedAt": "%s",\n' "$generated_at" >> "$OUT_FILE"
printf '  "serviceCount": %s,\n' "$service_count" >> "$OUT_FILE"
printf '  "services": [\n' >> "$OUT_FILE"

idx=0
while IFS='|' read -r route upstream source_file; do
  [ -n "$route" ] || continue
  idx=$((idx + 1))

  route_norm=$(normalize_route "$route")
  name=$(service_name_for_source "$source_file" "$route_norm")
  slug=$(slugify "$route_norm")
  icon=$(icon_for_service "$name")
  source_base=$(basename "$source_file")

  # Parse direct target from upstream (protocol://host:port)
  protocol=""
  host=""
  port=""
  if printf '%s' "$upstream" | grep -Eq '^[a-zA-Z]+://'; then
    protocol=$(printf '%s' "$upstream" | sed -E 's#^([a-zA-Z]+)://.*#\1#')
    hostport=$(printf '%s' "$upstream" | sed -E 's#^[a-zA-Z]+://([^/]+).*$#\1#')
    host=$(printf '%s' "$hostport" | sed -E 's#:.*$##')
    if printf '%s' "$hostport" | grep -q ':'; then
      port=$(printf '%s' "$hostport" | sed -E 's#^.*:([0-9]+)$#\1#')
    elif [ "$protocol" = "https" ]; then
      port="443"
    else
      port="80"
    fi
  fi

  [ "$idx" -gt 1 ] && printf ',\n' >> "$OUT_FILE"

  printf '    {\n' >> "$OUT_FILE"
  printf '      "name": "%s",\n' "$(json_escape "$name")" >> "$OUT_FILE"
  printf '      "slug": "%s",\n' "$(json_escape "$slug")" >> "$OUT_FILE"
  printf '      "route": "%s",\n' "$(json_escape "$route_norm")" >> "$OUT_FILE"
  printf '      "proxyUrl": "%s",\n' "$(json_escape "$route_norm")" >> "$OUT_FILE"
  printf '      "sourceFile": "%s",\n' "$(json_escape "$source_base")" >> "$OUT_FILE"
  printf '      "icon": "%s",\n' "$(json_escape "$icon")" >> "$OUT_FILE"
  printf '      "upstream": "%s",\n' "$(json_escape "$upstream")" >> "$OUT_FILE"
  printf '      "direct": {\n' >> "$OUT_FILE"
  printf '        "protocol": "%s",\n' "$(json_escape "$protocol")" >> "$OUT_FILE"
  printf '        "host": "%s",\n' "$(json_escape "$host")" >> "$OUT_FILE"
  printf '        "port": "%s",\n' "$(json_escape "$port")" >> "$OUT_FILE"
  printf '        "path": "%s"\n' "$(json_escape "$route_norm")" >> "$OUT_FILE"
  printf '      }\n' >> "$OUT_FILE"
  printf '    }' >> "$OUT_FILE"
done < "$TMP_UNIQ"

printf '\n  ]\n}\n' >> "$OUT_FILE"

printf 'Generated %s service(s) at %s\n' "$service_count" "$OUT_FILE"
