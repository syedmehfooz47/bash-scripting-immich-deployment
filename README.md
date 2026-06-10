# Immich Docker Deployment

A minimal Bash script that deploys Immich using the official release files.

## Requirements
- Ubuntu (or any Linux) with Docker and Docker Compose installed.
- `curl` or `wget` (the script will use whichever is available).

## Quick one‑liner installation
```bash
curl -fsSL https://raw.githubusercontent.com/syedmehfooz47/bash-scripting-immich-deployment/main/deploy-immich.sh -o /tmp/deploy-immich.sh
sudo bash /tmp/deploy-immich.sh
rm /tmp/deploy-immich.sh
```

The script will:
1. Create the `immich-app` directory.
2. Download the latest `docker-compose.yml` and `example.env` from the official Immich release.
3. Set a default `DB_PASSWORD=password` (please edit `.env` afterwards).
4. Start the Immich stack with `docker compose up -d`.

## Post‑deployment
- Check the containers: `docker compose ps` (or `docker-compose ps`).
- View logs: `docker compose logs -f`.
- Edit `.env` to customise settings such as `UPLOAD_LOCATION`, `DB_PASSWORD`, etc.

## Troubleshooting
- Ensure Docker is running: `docker ps`.
- If the script fails to download files, verify network connectivity and that `curl`/`wget` are installed.

--- 

## Uninstall Immich

The repository now provides a helper script to clean up all Immich resources.

```bash
curl -fsSL https://raw.githubusercontent.com/syedmehfooz47/bash-scripting-immich-deployment/main/uninstall-immich.sh -o /tmp/uninstall-immich.sh
sudo bash /tmp/uninstall-immich.sh
rm /tmp/uninstall-immich.sh
```

The script performs the following steps:

1. Brings down the Docker Compose stack.
2. Stops and removes stray containers.
3. Deletes the model‑cache volume.
4. Removes the Docker network.
5. Removes Immich Docker images.
6. Deletes the on‑disk `immich-app` folder.
7. Verifies a clean state.

--- 

**Version:** 1.1 | **Status:** Ready
