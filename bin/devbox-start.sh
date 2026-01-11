#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${GREEN}Dreamkastアプリケーションを起動します...${NC}"

# 1. 環境変数ファイルの存在確認
if [ ! -f .env-local.devbox ]; then
  echo -e "${RED}❌ .env-local.devboxが見つかりません${NC}"
  echo "devbox run setup を実行してください"
  exit 1
fi

# 2. Docker Composeサービスの起動
echo "Docker Composeサービスを起動しています..."
docker compose up -d db redis localstack nginx fifo-worker

# サービス起動待機
echo "サービスの起動を待機しています(最大60秒)..."
timeout=60
elapsed=0
while ! docker compose ps | grep -q "db.*healthy\|db.*running"; do
  if [ $elapsed -ge $timeout ]; then
    echo -e "${RED}❌ DBサービスの起動がタイムアウトしました${NC}"
    echo "docker compose logs db でログを確認してください"
    exit 1
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done

# 3. DBマイグレーション
echo "データベースマイグレーションを実行しています..."
bundle exec rails db:migrate

# 4. シードデータ投入
echo "シードデータを投入しています..."
bundle exec rails db:seed

# 5. Foremanでアプリケーション起動
echo ""
echo -e "${GREEN}アプリケーションを起動しています...${NC}"
echo "アクセス先: http://localhost:8080"
echo ""
bundle exec foreman start -f Procfile.dev -e .env-local.devbox
