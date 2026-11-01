#!/usr/bin/env bash
# Deploy Swiss Energy Assistant to the Hostinger VPS.
#   Domain:  https://sea.supercharged.ch
#   Web app: 127.0.0.1:7401   API: 127.0.0.1:7400
#   Docker Compose project "sea" in ~/sea
#
# Usage:
#   ./deploy/deploy.sh              # full build, sync, (re)start, verify
#   ./deploy/deploy.sh update       # same as above (alias)
#   ./deploy/deploy.sh stop         # stop all containers
#   ./deploy/deploy.sh logs         # tail logs
#   ./deploy/deploy.sh status       # show container status
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
REMOTE_HOST="${REMOTE_HOST:-hostinger}"
REMOTE_PATH="sea"
DOMAIN="sea.supercharged.ch"
NGINX_CONF="nginx-sea.supercharged.ch.conf"
LOCAL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE="cd ~/${REMOTE_PATH} && docker compose -f docker-compose.prod.yml"

# --- Subcommands ---
case "${1:-deploy}" in
    stop)
        echo -e "${YELLOW}Stopping SEA containers...${NC}"
        ssh "${REMOTE_HOST}" "${COMPOSE} down"
        exit 0 ;;
    logs)
        ssh "${REMOTE_HOST}" "${COMPOSE} logs -f --tail=100"
        exit 0 ;;
    status)
        ssh "${REMOTE_HOST}" "${COMPOSE} ps --format 'table {{.Service}}\t{{.Status}}'"
        exit 0 ;;
    deploy|update) ;; # continue below
    *)
        echo "Usage: $0 [deploy|update|stop|logs|status]"; exit 1 ;;
esac

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Swiss Energy Assistant — Deploy to ${REMOTE_HOST}  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
cd "${LOCAL_PATH}"

# [1/7] SSH check
echo -e "\n${YELLOW}[1/7] Checking SSH connection...${NC}"
ssh -q -o BatchMode=yes -o ConnectTimeout=10 "${REMOTE_HOST}" exit \
    || { echo -e "${RED}Cannot connect to ${REMOTE_HOST} without a password.${NC}"; exit 1; }
echo -e "${GREEN}  ✓ Connected${NC}"

# [2/7] Build frontend
echo -e "\n${YELLOW}[2/7] Building Next.js frontend...${NC}"
cd "${LOCAL_PATH}/frontend"
npm run build 2>&1 | tail -5
echo -e "${GREEN}  ✓ Frontend built${NC}"
cd "${LOCAL_PATH}"

# [3/7] Sync files
echo -e "\n${YELLOW}[3/7] Syncing files to VPS...${NC}"
ssh "${REMOTE_HOST}" "mkdir -p ~/${REMOTE_PATH}"

# Create remote directories
ssh "${REMOTE_HOST}" "mkdir -p ~/${REMOTE_PATH}/backend ~/${REMOTE_PATH}/frontend ~/${REMOTE_PATH}/deploy"

# Backend
rsync -az --delete \
    --exclude 'venv' --exclude '.venv' --exclude '__pycache__' --exclude '*.pyc' \
    --exclude '.pytest_cache' --exclude '*.egg-info' --exclude 'tests' \
    backend/app/ "${REMOTE_HOST}:${REMOTE_PATH}/backend/app/"
rsync -az backend/pyproject.toml "${REMOTE_HOST}:${REMOTE_PATH}/backend/"

# Frontend (full source for Docker build)
rsync -az --delete \
    --exclude 'node_modules' --exclude '.next' --exclude '.env.local' \
    frontend/ "${REMOTE_HOST}:${REMOTE_PATH}/frontend/"

# Deploy files
rsync -az docker-compose.prod.yml "${REMOTE_HOST}:${REMOTE_PATH}/"
rsync -az --delete deploy/ "${REMOTE_HOST}:${REMOTE_PATH}/deploy/"

echo -e "${GREEN}  ✓ Files synced${NC}"

# [4/7] Ensure .env exists
echo -e "\n${YELLOW}[4/7] Checking .env...${NC}"
ssh "${REMOTE_HOST}" "
    set -e; cd ~/${REMOTE_PATH}
    if [ -f .env ]; then
        echo '.env already exists (not overwriting)'
    else
        umask 077
        pw=\$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
        jwt=\$(python3 -c 'import secrets; print(secrets.token_urlsafe(48))')
        cat > .env <<ENV
POSTGRES_PASSWORD=\$pw
SECRET_KEY=\$jwt
JWT_SECRET_KEY=\$jwt
APP_ENV=production
DEBUG=false
NEXT_PUBLIC_API_BASE_URL=https://${DOMAIN}
NEXT_PUBLIC_USE_MOCK_API=true
ENV
        echo 'Created .env with generated secrets (mode 600)'
    fi"
echo -e "${GREEN}  ✓ .env ready${NC}"

# [5/7] Build and start
echo -e "\n${YELLOW}[5/7] Building and starting containers on VPS...${NC}"
ssh "${REMOTE_HOST}" "${COMPOSE} up -d --build --remove-orphans" 2>&1 | tail -15
echo -e "${GREEN}  ✓ Containers started${NC}"

# [6/7] Verify
echo -e "\n${YELLOW}[6/7] Verifying services...${NC}"
api_ok=""
for i in $(seq 1 30); do
    api_ok=$(ssh "${REMOTE_HOST}" "curl -sf http://127.0.0.1:7400/healthz 2>/dev/null || true")
    [ -n "$api_ok" ] && break
    sleep 3
done

if [ -n "$api_ok" ]; then
    echo -e "${GREEN}  ✓ API (127.0.0.1:7400): healthy${NC}"
else
    echo -e "${RED}  ✗ API not responding after 90s${NC}"
fi

web_code=$(ssh "${REMOTE_HOST}" "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:7401/ 2>/dev/null || echo '000'")
if [ "$web_code" = "200" ]; then
    echo -e "${GREEN}  ✓ Web (127.0.0.1:7401): HTTP ${web_code}${NC}"
else
    echo -e "${RED}  ✗ Web (127.0.0.1:7401): HTTP ${web_code}${NC}"
fi

echo ""
ssh "${REMOTE_HOST}" "${COMPOSE} ps --format 'table {{.Service}}\t{{.Status}}'"

# [7/7] nginx
echo -e "\n${YELLOW}[7/7] nginx...${NC}"
if ssh "${REMOTE_HOST}" "[ -e /etc/nginx/sites-enabled/${DOMAIN}.conf ]"; then
    echo -e "${GREEN}  ✓ nginx site already installed${NC}"
else
    echo -e "${YELLOW}  The nginx site is not installed yet. Run once on the VPS:${NC}"
    echo ""
    echo "  sudo cp ~/${REMOTE_PATH}/deploy/${NGINX_CONF} /etc/nginx/sites-available/${DOMAIN}.conf"
    echo "  sudo ln -sf /etc/nginx/sites-available/${DOMAIN}.conf /etc/nginx/sites-enabled/${DOMAIN}.conf"
    echo "  sudo nginx -t && sudo nginx -s reload"
    echo ""
fi

echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ Deployed! https://${DOMAIN}             ║${NC}"
echo -e "${GREEN}║  API docs: https://${DOMAIN}/docs           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
