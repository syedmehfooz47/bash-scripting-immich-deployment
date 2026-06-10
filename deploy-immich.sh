#!/usr/bin/env bash
set -euo pipefail

# Minimal deploy script: download, sanitize, set DB_PASSWORD=password, and start compose.

RepoRawBase="https://github.com/immich-app/immich/releases/latest/download"
TARGET_DIR="immich-app"

download() {
    local url="$1" dest="$2"
    echo "Downloading: $url -> $dest"
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fSL --retry 3 -o "$dest" "$url"; then
            echo "curl failed fetching $url" >&2
            return 22
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -qO "$dest" "$url"; then
            echo "wget failed fetching $url" >&2
            return 22
        fi
    else
        echo "Install curl or wget and retry." >&2
        return 2
    fi
}



sanitize_compose() {
    echo "Sanitizing docker-compose.yml (removing top‑level name)..."
    local f="docker-compose.yml"
    [ -f "$f" ] || return 0
    sed -i.bak -E '/^[[:space:]]*name:.*$/d' "$f" || true
}

set_db_password_literal() {
    echo "Ensuring DB_PASSWORD is set (default: password)..."
    if grep -q '^DB_PASSWORD=' .env 2>/dev/null; then
        sed -i.bak -E 's/^DB_PASSWORD=.*/DB_PASSWORD=password/' .env || true
    else
        echo 'DB_PASSWORD=password' >> .env
    fi
}

start_stack() {
    echo "Starting Immich stack with Docker Compose..."
    if docker compose version >/dev/null 2>&1; then
        docker compose up --remove-orphans -d
    elif command -v docker-compose >/dev/null 2>&1; then
        docker-compose up --remove-orphans -d
    else
        echo "No docker compose command found; install Docker Compose." >&2
        return 2
    fi
}

create_target_dir() {
    echo "Creating target directory $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
    cd "$TARGET_DIR"
}

main() {
    echo "********** IMMICH DEPLOYMENT STARTED (simple mode) *********"
    create_target_dir
    download "$RepoRawBase/docker-compose.yml" docker-compose.yml

    download "$RepoRawBase/example.env" .env
    sanitize_compose
    set_db_password_literal
    start_stack
    echo "Done. Check containers with: docker compose ps  (or: docker-compose ps)"
}

main "$@"
