#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 環境変数ファイルの読み込み
if [ -f .env-local.devbox ]; then
  set -a
  source .env-local.devbox
  set +a
fi

echo -e "${GREEN}AWS認証を開始します...${NC}"

# 1. AWS SSO設定の確認
SSO_PROFILE="dreamkast"  # プロファイル名を統一

if ! aws configure list-profiles 2>/dev/null | grep -q "^${SSO_PROFILE}$"; then
  echo -e "${YELLOW}AWS SSOプロファイルが見つかりません。設定を開始します...${NC}"
  echo ""
  echo "以下の情報を入力してください:"
  echo "  SSO session name: dreamkast"
  echo "  SSO start URL: (Dreamkastチームから取得)"
  echo "  SSO region: ap-northeast-1"
  echo "  SSO registration scopes: sso:account:access"
  echo ""

  aws configure sso --profile "$SSO_PROFILE"
else
  echo "AWS SSOプロファイル '$SSO_PROFILE' が見つかりました"
fi

# 2. AWS SSOログイン
echo "AWS SSOにログインしています..."
aws sso login --profile "$SSO_PROFILE"

# 3. ECRログイン
echo "ECRにログインしています..."
aws ecr get-login-password --region ap-northeast-1 --profile "$SSO_PROFILE" | \
  docker login --username AWS --password-stdin 607167088920.dkr.ecr.ap-northeast-1.amazonaws.com

# 4. 認証状態の確認
echo "認証状態を確認しています..."
if aws sts get-caller-identity --profile "$SSO_PROFILE" > /dev/null 2>&1; then
  echo -e "${GREEN}✅ AWS認証が成功しました${NC}"
  aws sts get-caller-identity --profile "$SSO_PROFILE"
else
  echo -e "${RED}❌ AWS認証に失敗しました${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}✅ ECRログインが完了しました${NC}"
echo ""
echo "次のステップ: devbox run fetch-secrets で認証情報を取得"
