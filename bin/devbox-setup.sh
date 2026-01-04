#!/usr/bin/env bash
set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# プロジェクトルート取得
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${GREEN}Dreamkast devbox セットアップを開始します...${NC}"

# 1. 環境変数テンプレートのコピー
if [ ! -f .env-local.devbox ]; then
  echo "環境変数ファイルをコピーしています..."
  cp .env-local.devbox.example .env-local.devbox
  echo -e "${YELLOW}⚠️  .env-local.devboxを確認してください${NC}"
  echo "   認証情報は以下のコマンドで自動取得できます:"
  echo "   devbox run fetch-secrets"
fi

# 2. Node.js依存のインストール
echo "Node.js依存をインストールしています..."
yarn install --check-files

# 3. Ruby依存のインストール
echo "Ruby依存をインストールしています..."
bundle install

# 4. Docker Composeサービスの起動確認
echo "Docker Composeサービスを起動しています..."
docker compose up -d db redis localstack nginx ui fifo-worker

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

# 5. 健全性チェック
echo "データベース接続を確認しています..."
if ! mysql -h 127.0.0.1 -u root -proot -e "SELECT 1" > /dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  MySQL接続に失敗しました。Docker Composeログを確認してください。${NC}"
  echo "   docker compose logs db"
fi

echo "Redis接続を確認しています..."
if ! redis-cli -h 127.0.0.1 ping > /dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  Redis接続に失敗しました。Docker Composeログを確認してください。${NC}"
  echo "   docker compose logs redis"
fi

# 6. 完了メッセージ
echo ""
echo -e "${GREEN}✅ セットアップが完了しました!${NC}"
echo ""
echo "次のステップ:"
echo "  1. AWS認証: devbox run auth"
echo "  2. 認証情報取得: devbox run fetch-secrets"
echo "  3. アプリケーション起動: devbox run start"
