#!/usr/bin/env bash
set -euo pipefail

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# プロジェクトルート取得
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${GREEN}Dreamkast devbox セットアップを開始します...${NC}"

# 1. Node.js依存のインストール
echo "Node.js依存をインストールしています..."
yarn install --check-files

# 2. Ruby依存のインストール
echo "Ruby依存をインストールしています..."
bundle install

# 3. 完了メッセージ
echo ""
echo -e "${GREEN}✅ セットアップが完了しました!${NC}"
echo ""
echo "次のステップ:"
echo "  1. AWS認証とシークレット取得: source bin/devbox-auth.sh"
echo "  2. アプリケーション起動: devbox run start"
echo ""
echo -e "${YELLOW}注意: 認証情報はファイルに保存されず、シェルセッション内でのみ有効です${NC}"
