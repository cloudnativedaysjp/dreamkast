#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

SSO_PROFILE="dreamkast"
AWS_REGION="us-west-2"

echo -e "${GREEN}AWS Secrets Managerから認証情報を取得します...${NC}"

# 環境変数ファイルの存在確認
if [ ! -f .env-local.devbox ]; then
  echo -e "${RED}❌ .env-local.devboxが見つかりません${NC}"
  echo "devbox run setup を先に実行してください"
  exit 1
fi

# AWS認証確認
if ! aws sts get-caller-identity --profile "$SSO_PROFILE" > /dev/null 2>&1; then
  echo -e "${RED}❌ AWS認証が完了していません${NC}"
  echo "devbox run auth を先に実行してください"
  exit 1
fi

# 一時ファイル作成
TEMP_ENV=$(mktemp)
trap "rm -f $TEMP_ENV" EXIT

# 既存の.env-local.devboxをコピー
cp .env-local.devbox "$TEMP_ENV"

# 1. dreamkast/reviewapp-env から Auth0設定を取得
echo "Auth0設定を取得しています..."
REVIEWAPP_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id dreamkast/reviewapp-env \
  --region "$AWS_REGION" \
  --profile "$SSO_PROFILE" \
  --query SecretString \
  --output text 2>/dev/null)

if [ -n "$REVIEWAPP_SECRET" ]; then
  # JSONから各値を抽出して環境変数に設定
  AUTH0_CLIENT_ID=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_CLIENT_ID // empty')
  AUTH0_CLIENT_SECRET=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_CLIENT_SECRET // empty')
  AUTH0_DOMAIN=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_DOMAIN // empty')

  # .env-local.devboxに追記（既存の値を上書きしない）
  if [ -n "$AUTH0_CLIENT_ID" ]; then
    if ! grep -q "^export AUTH0_CLIENT_ID=" "$TEMP_ENV"; then
      echo "export AUTH0_CLIENT_ID=\"$AUTH0_CLIENT_ID\"" >> "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_IDを設定しました"
    else
      sed -i.bak "s|^export AUTH0_CLIENT_ID=.*|export AUTH0_CLIENT_ID=\"$AUTH0_CLIENT_ID\"|" "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_IDを更新しました"
    fi
  fi

  if [ -n "$AUTH0_CLIENT_SECRET" ]; then
    if ! grep -q "^export AUTH0_CLIENT_SECRET=" "$TEMP_ENV"; then
      echo "export AUTH0_CLIENT_SECRET=\"$AUTH0_CLIENT_SECRET\"" >> "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_SECRETを設定しました"
    else
      sed -i.bak "s|^export AUTH0_CLIENT_SECRET=.*|export AUTH0_CLIENT_SECRET=\"$AUTH0_CLIENT_SECRET\"|" "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_SECRETを更新しました"
    fi
  fi

  if [ -n "$AUTH0_DOMAIN" ]; then
    if ! grep -q "^export AUTH0_DOMAIN=" "$TEMP_ENV"; then
      echo "export AUTH0_DOMAIN=\"$AUTH0_DOMAIN\"" >> "$TEMP_ENV"
      echo "  ✓ AUTH0_DOMAINを設定しました"
    else
      sed -i.bak "s|^export AUTH0_DOMAIN=.*|export AUTH0_DOMAIN=\"$AUTH0_DOMAIN\"|" "$TEMP_ENV"
      echo "  ✓ AUTH0_DOMAINを更新しました"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  Auth0設定の取得に失敗しました${NC}"
fi

# 2. dreamkast/rails-app-secret から RAILS_MASTER_KEY を取得
echo "Rails Master Keyを取得しています..."
RAILS_MASTER_KEY=$(aws secretsmanager get-secret-value \
  --secret-id dreamkast/rails-app-secret \
  --region "$AWS_REGION" \
  --profile "$SSO_PROFILE" \
  --query SecretString \
  --output text 2>/dev/null)

if [ -n "$RAILS_MASTER_KEY" ]; then
  if ! grep -q "^export RAILS_MASTER_KEY=" "$TEMP_ENV"; then
    echo "export RAILS_MASTER_KEY=\"$RAILS_MASTER_KEY\"" >> "$TEMP_ENV"
    echo "  ✓ RAILS_MASTER_KEYを設定しました"
  else
    sed -i.bak "s|^export RAILS_MASTER_KEY=.*|export RAILS_MASTER_KEY=\"$RAILS_MASTER_KEY\"|" "$TEMP_ENV"
    echo "  ✓ RAILS_MASTER_KEYを更新しました"
  fi
else
  echo -e "${YELLOW}⚠️  RAILS_MASTER_KEYの取得に失敗しました${NC}"
fi

# 更新した環境変数ファイルを保存
mv "$TEMP_ENV" .env-local.devbox
rm -f .env-local.devbox.bak

echo ""
echo -e "${GREEN}✅ 認証情報の取得が完了しました${NC}"
echo ""
echo "次のステップ: devbox run start でアプリケーションを起動"
