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
  if [ ! -f .env-local.devbox.example ]; then
    echo -e "${RED}❌ .env-local.devbox.exampleが見つかりません${NC}"
    echo "現在のディレクトリ: $(pwd)"
    ls -la .env-local.devbox.example || echo "ファイルが存在しません"
    exit 1
  fi
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

# 4. 完了メッセージ
echo ""
echo -e "${GREEN}✅ セットアップが完了しました!${NC}"
echo ""
echo "次のステップ:"
echo "  1. AWS認証とシークレット取得: devbox run auth"
echo "  2. アプリケーション起動: devbox run start"
