#!/usr/bin/env bash

set -e

echo "Starting Immich cleanup and uninstall..."

# Bring the stack down
echo "Bringing down Docker Compose stack..."
# 1️⃣ Bring the stack down

echo "🧹 Bringing down Docker Compose stack..."
# The compose files are located in the ~/immich-app directory created by the install script.
if [ -d "${HOME}/immich-app" ]; then
  cd "${HOME}/immich-app"
  if command -v docker-compose > /dev/null; then
    sudo docker-compose down || true
  else
    sudo docker compose down || true
  fi
  # Return to original directory
  cd - > /dev/null
else
  echo "⚠️ No immich-app directory found; skipping docker-compose down."
fi

# 2️⃣ Remove stray containers
echo "Removing stray containers..."
sudo docker stop immich_server immich_postgres immich_machine_learning immich_redis || true
sudo docker rm -f immich_server immich_postgres immich_machine_learning immich_redis || true

# 3️⃣ Delete the model‑cache volume
echo "Deleting model‑cache volume..."
sudo docker volume rm immich-app_model-cache || true

# 4️⃣ Delete the network
echo "Deleting Docker network..."
sudo docker network rm immich-app_default || true

# 5️⃣ Delete the images
echo "Removing Immich Docker images..."
sudo docker rmi ghcr.io/immich-app/immich-server:v2 \
                ghcr.io/immich-app/immich-machine-learning:v2 \
                ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0 \
                valkey/valkey:9 || true

# 6️⃣ Delete the on‑disk folder
echo "Removing on‑disk Immich folder..."
sudo rm -rf ~/immich-app

# 7️⃣ Verify clean state
echo "Verifying clean state..."
docker ps --filter "name=immich"
docker network ls --filter "name=immich"
docker volume ls --filter "name=immich"
docker images | grep immich || true

echo "Immich has been fully removed."
