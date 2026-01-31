#!/usr/bin/env bash
# このスクリプトは source で実行してください: source bin/devbox-auth.sh
# シークレットを環境変数にエクスポートし、ファイルには書き出しません

# sourceで実行する場合、set -e は親シェルを終了させる可能性があるため使用しない
# 代わりに各コマンドの戻り値を個別にチェックする

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# カレントディレクトリは変更しない（sourceで実行するため）
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
# 使い方: DEVBOX_REMOTE=1 source bin/devbox-auth.sh
echo "AWS SSOにログインしています..."
if [[ -n "${DEVBOX_REMOTE:-}" ]]; then
  echo -e "${YELLOW}⚠️  リモート環境モードで実行します${NC}"
  echo "以下のURLとコードをブラウザで開いて認証してください:"
  if ! aws sso login --profile "$SSO_PROFILE" --use-device-code; then
    echo -e "${RED}❌ AWS SSOログインに失敗しました${NC}"
    return 1 2>/dev/null || true
  fi
else
  if ! aws sso login --profile "$SSO_PROFILE"; then
    echo -e "${RED}❌ AWS SSOログインに失敗しました${NC}"
    return 1 2>/dev/null || true
  fi
fi

# 3. 認証状態の確認
echo "認証状態を確認しています..."
if aws sts get-caller-identity --profile "$SSO_PROFILE" > /dev/null 2>&1; then
  echo -e "${GREEN}✅ AWS認証が成功しました${NC}"
  aws sts get-caller-identity --profile "$SSO_PROFILE"
else
  echo -e "${RED}❌ AWS認証に失敗しました${NC}"
  echo "aws sts get-caller-identity --profile $SSO_PROFILE を実行して詳細を確認してください"
  # sourceで実行されている場合はreturn、そうでなければfalseを返す（exitはシェルを終了させるので使わない）
  return 1 2>/dev/null || true
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

# 5. AWSクレデンシャルを環境変数にエクスポート
echo "AWS認証情報を環境変数にエクスポートしています..."
AWS_CREDENTIALS=$(aws configure export-credentials --profile "$SSO_PROFILE" --format env 2>/dev/null || echo "")

if [ -n "$AWS_CREDENTIALS" ]; then
  # export形式の環境変数を評価
  eval "$AWS_CREDENTIALS"
  echo -e "${GREEN}✅ AWS認証情報を環境変数にエクスポートしました${NC}"
else
  echo -e "${YELLOW}⚠️  AWS認証情報の取得に失敗しました${NC}"
fi

# 6. シークレット取得と環境変数へのエクスポート
echo ""
echo -e "${GREEN}AWS Secrets Managerから認証情報を取得します...${NC}"

# 6.1. dreamkast/reviewapp-env から Auth0設定を取得
echo "Auth0設定を取得しています..."
REVIEWAPP_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id dreamkast/reviewapp-env \
  --region "$AWS_SECRETS_REGION" \
  --profile "$SSO_PROFILE" \
  --query SecretString \
  --output text 2>/dev/null || echo "")

if [ -n "$REVIEWAPP_SECRET" ]; then
  # JSONから各値を抽出して環境変数にエクスポート
  export AUTH0_CLIENT_ID=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_CLIENT_ID // empty')
  export AUTH0_CLIENT_SECRET=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_CLIENT_SECRET // empty')
  export AUTH0_DOMAIN=$(echo "$REVIEWAPP_SECRET" | jq -r '.AUTH0_DOMAIN // empty')

  [ -n "$AUTH0_CLIENT_ID" ] && echo "  ✓ AUTH0_CLIENT_IDをエクスポートしました"
  [ -n "$AUTH0_CLIENT_SECRET" ] && echo "  ✓ AUTH0_CLIENT_SECRETをエクスポートしました"
  [ -n "$AUTH0_DOMAIN" ] && echo "  ✓ AUTH0_DOMAINをエクスポートしました"
else
  echo -e "${YELLOW}⚠️  Auth0設定の取得に失敗しました（権限がない可能性があります）${NC}"
fi

# 6.2. dreamkast/rails-app-secret から RAILS_MASTER_KEY を取得
echo "Rails Master Keyを取得しています..."
RAILS_MASTER_KEY_VALUE=$(aws secretsmanager get-secret-value \
  --secret-id dreamkast/rails-app-secret \
  --region "$AWS_SECRETS_REGION" \
  --profile "$SSO_PROFILE" \
  --query SecretString \
  --output text 2>/dev/null || echo "")

if [ -n "$RAILS_MASTER_KEY_VALUE" ]; then
  export RAILS_MASTER_KEY="$RAILS_MASTER_KEY_VALUE"
  echo "  ✓ RAILS_MASTER_KEYをエクスポートしました"
else
  echo -e "${YELLOW}⚠️  RAILS_MASTER_KEYの取得に失敗しました（権限がない可能性があります）${NC}"
fi

echo ""
echo -e "${GREEN}✅ 認証とシークレット取得が完了しました${NC}"
echo ""
echo "次のステップ: devbox run start でアプリケーションを起動"
echo ""
echo -e "${YELLOW}注意: この環境変数は現在のシェルセッションでのみ有効です${NC}"
