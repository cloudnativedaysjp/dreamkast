#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 環境変数ファイルの読み込み（.env形式）
if [ -f .env-local.devbox ]; then
  set -a
  source .env-local.devbox
  set +a
fi

echo -e "${GREEN}AWS認証とシークレット取得を開始します...${NC}"

# 定数定義
SSO_PROFILE="dreamkast"
SSO_START_URL="https://d-95675816a0.awsapps.com/start/"
SSO_REGION="ap-northeast-1"
AWS_SECRETS_REGION="us-west-2"

# 1. AWS SSO設定の確認と自動設定
if ! aws configure list-profiles 2>/dev/null | grep -q "^${SSO_PROFILE}$"; then
  echo -e "${YELLOW}AWS SSOプロファイルが見つかりません。自動設定を開始します...${NC}"

  # AWS CLI設定ディレクトリの作成
  mkdir -p ~/.aws

  # SSO設定を自動的に追加
  cat >> ~/.aws/config <<EOF

[profile ${SSO_PROFILE}]
sso_session = ${SSO_PROFILE}
sso_account_id = 607167088920
sso_role_name = AdministratorAccess
region = ${SSO_REGION}
output = json

[sso-session ${SSO_PROFILE}]
sso_start_url = ${SSO_START_URL}
sso_region = ${SSO_REGION}
sso_registration_scopes = sso:account:access
EOF

  echo -e "${GREEN}✅ AWS SSOプロファイルを自動設定しました${NC}"
else
  echo "AWS SSOプロファイル '$SSO_PROFILE' が見つかりました"

  # 既存設定のロール名を確認・修正
  CURRENT_ROLE=$(aws configure get sso_role_name --profile "$SSO_PROFILE" 2>/dev/null || echo "")
  if [ "$CURRENT_ROLE" != "AdministratorAccess" ]; then
    echo -e "${YELLOW}⚠️  ロール名が古い設定です。AdministratorAccessに更新しています...${NC}"
    aws configure set sso_role_name AdministratorAccess --profile "$SSO_PROFILE"
    echo -e "${GREEN}✅ ロール名を更新しました${NC}"

    # SSO cacheをクリアして再認証を促す
    echo "SSOキャッシュをクリアしています..."
    rm -rf ~/.aws/sso/cache/*
    rm -rf ~/.aws/cli/cache/*
  fi
fi

# 2. AWS SSOログイン
# リモート環境（非TTY）の場合は環境変数で --use-device-code オプションを使用
# 使い方: DEVBOX_REMOTE=1 devbox run auth
echo "AWS SSOにログインしています..."
if [[ -n "${DEVBOX_REMOTE:-}" ]]; then
  echo -e "${YELLOW}⚠️  リモート環境モードで実行します${NC}"
  echo "以下のURLとコードをブラウザで開いて認証してください:"
  aws sso login --profile "$SSO_PROFILE" --use-device-code
else
  aws sso login --profile "$SSO_PROFILE"
fi

# 3. 認証状態の確認
echo "認証状態を確認しています..."
if aws sts get-caller-identity --profile "$SSO_PROFILE" > /dev/null 2>&1; then
  echo -e "${GREEN}✅ AWS認証が成功しました${NC}"
  aws sts get-caller-identity --profile "$SSO_PROFILE"
else
  echo -e "${RED}❌ AWS認証に失敗しました${NC}"
  echo "aws sts get-caller-identity --profile $SSO_PROFILE を実行して詳細を確認してください"
  exit 1
fi

# 4. ECRログイン
echo "ECRにログインしています..."
ECR_PASSWORD=$(aws ecr get-login-password --region ${SSO_REGION} --profile "$SSO_PROFILE" 2>/dev/null || echo "")
if [ -n "$ECR_PASSWORD" ]; then
  echo "$ECR_PASSWORD" | docker login --username AWS --password-stdin 607167088920.dkr.ecr.${SSO_REGION}.amazonaws.com
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ ECRログインが成功しました${NC}"
  else
    echo -e "${YELLOW}⚠️  ECRログインに失敗しました${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  ECRパスワードの取得に失敗しました（権限がない可能性があります）${NC}"
fi

# 5. クレデンシャル取得とファイル保存
echo "AWS認証情報をファイルに保存しています..."
AWS_CREDENTIALS=$(aws configure export-credentials --profile "$SSO_PROFILE" --format env 2>/dev/null || echo "")

if [ -n "$AWS_CREDENTIALS" ]; then
  # 環境変数ファイルに認証情報を設定
  if [ -f .env-local.devbox ]; then
    TEMP_ENV=$(mktemp)
    cp .env-local.devbox "$TEMP_ENV"

    # 既存のAWS認証情報を削除
    sed -i.bak '/^AWS_ACCESS_KEY_ID=/d' "$TEMP_ENV"
    sed -i.bak '/^AWS_SECRET_ACCESS_KEY=/d' "$TEMP_ENV"
    sed -i.bak '/^AWS_SESSION_TOKEN=/d' "$TEMP_ENV"

    # 新しい認証情報を追加（.env形式）
    echo "$AWS_CREDENTIALS" >> "$TEMP_ENV"

    mv "$TEMP_ENV" .env-local.devbox
    rm -f .env-local.devbox.bak

    echo -e "${GREEN}✅ AWS認証情報を.env-local.devboxに設定しました${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  AWS認証情報の取得に失敗しました${NC}"
fi

# 6. シークレット取得
echo ""
echo -e "${GREEN}AWS Secrets Managerから認証情報を取得します...${NC}"

# 環境変数ファイルの存在確認
if [ ! -f .env-local.devbox ]; then
  echo -e "${RED}❌ .env-local.devboxが見つかりません${NC}"
  echo "devbox run setup を先に実行してください"
  exit 1
fi

# 一時ファイル作成
TEMP_ENV=$(mktemp)
trap "rm -f $TEMP_ENV" EXIT

# 既存の.env-local.devboxをコピー
cp .env-local.devbox "$TEMP_ENV"

# 6.1. dreamkast/reviewapp-env から Auth0設定を取得
echo "Auth0設定を取得しています..."
REVIEWAPP_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id dreamkast/reviewapp-env \
  --region "$AWS_SECRETS_REGION" \
  --profile "$SSO_PROFILE" \
  --query SecretString \
  --output text 2>/dev/null || echo "")

if [ -n "$REVIEWAPP_SECRET" ]; then
  # JSONから各値を抽出して環境変数に設定
  AUTH0_CLIENT_ID=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_CLIENT_ID // empty')
  AUTH0_CLIENT_SECRET=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_CLIENT_SECRET // empty')
  AUTH0_DOMAIN=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_DOMAIN // empty')

  # .env-local.devboxに追記（既存の値を上書き）
  if [ -n "$AUTH0_CLIENT_ID" ]; then
    if ! grep -q "^AUTH0_CLIENT_ID=" "$TEMP_ENV"; then
      echo "AUTH0_CLIENT_ID=\"$AUTH0_CLIENT_ID\"" >> "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_IDを設定しました"
    else
      sed -i.bak "s|^AUTH0_CLIENT_ID=.*|AUTH0_CLIENT_ID=\"$AUTH0_CLIENT_ID\"|" "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_IDを更新しました"
    fi
  fi

  if [ -n "$AUTH0_CLIENT_SECRET" ]; then
    if ! grep -q "^AUTH0_CLIENT_SECRET=" "$TEMP_ENV"; then
      echo "AUTH0_CLIENT_SECRET=\"$AUTH0_CLIENT_SECRET\"" >> "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_SECRETを設定しました"
    else
      sed -i.bak "s|^AUTH0_CLIENT_SECRET=.*|AUTH0_CLIENT_SECRET=\"$AUTH0_CLIENT_SECRET\"|" "$TEMP_ENV"
      echo "  ✓ AUTH0_CLIENT_SECRETを更新しました"
    fi
  fi

  if [ -n "$AUTH0_DOMAIN" ]; then
    if ! grep -q "^AUTH0_DOMAIN=" "$TEMP_ENV"; then
      echo "AUTH0_DOMAIN=\"$AUTH0_DOMAIN\"" >> "$TEMP_ENV"
      echo "  ✓ AUTH0_DOMAINを設定しました"
    else
      sed -i.bak "s|^AUTH0_DOMAIN=.*|AUTH0_DOMAIN=\"$AUTH0_DOMAIN\"|" "$TEMP_ENV"
      echo "  ✓ AUTH0_DOMAINを更新しました"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  Auth0設定の取得に失敗しました（権限がない可能性があります）${NC}"
fi

# 6.2. dreamkast/rails-app-secret から RAILS_MASTER_KEY を取得
echo "Rails Master Keyを取得しています..."
RAILS_MASTER_KEY=$(aws secretsmanager get-secret-value \
  --secret-id dreamkast/rails-app-secret \
  --region "$AWS_SECRETS_REGION" \
  --profile "$SSO_PROFILE" \
  --query SecretString \
  --output text 2>/dev/null || echo "")

if [ -n "$RAILS_MASTER_KEY" ]; then
  if ! grep -q "^RAILS_MASTER_KEY=" "$TEMP_ENV"; then
    echo "RAILS_MASTER_KEY=\"$RAILS_MASTER_KEY\"" >> "$TEMP_ENV"
    echo "  ✓ RAILS_MASTER_KEYを設定しました"
  else
    sed -i.bak "s|^RAILS_MASTER_KEY=.*|RAILS_MASTER_KEY=\"$RAILS_MASTER_KEY\"|" "$TEMP_ENV"
    echo "  ✓ RAILS_MASTER_KEYを更新しました"
  fi
else
  echo -e "${YELLOW}⚠️  RAILS_MASTER_KEYの取得に失敗しました（権限がない可能性があります）${NC}"
fi

# 更新した環境変数ファイルを保存
mv "$TEMP_ENV" .env-local.devbox
rm -f .env-local.devbox.bak

echo ""
echo -e "${GREEN}✅ 認証とシークレット取得が完了しました${NC}"
echo ""
echo "次のステップ: devbox run start でアプリケーションを起動"
