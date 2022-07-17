Dreamkast platform
==================

## Table of content

- [Dreamkast](#dreamkast)
- [Dreamkast UI](#dreamkast-UI)
- [Dreamkast Infra](#dreamkast-infra)
- [Dreamkast Relasebot](#dreamkast-relasebot)
- [Dreamkast ReviewApp Operator](#dreamkast-reveiwapp-operator)
- [Dreamkast API Docs](#dreamkast-api-docs)

## Repositories / Components

### Dreamkast

Repository: https://github.com/cloudnativedaysjp/dreamkast/

#### これは何？

Ruby on Railsで書かれたDreamkast platformの中核となるコンポーネント。

- イベントのブランドサイト
- ユーザーのサインアップ
- タイムテーブル
- CFP受付
- Proposal採択
- 登壇者およびスポンサー向け情報の提供
- Talk管理
- IVSのコントロール
- UIのオンエア状態のコントロール
- 各種API

#### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

#### 依存しているサービス

- EKS(Kubernetes) - 実行環境として
- Auth0 - 認証認可
- Amazon RDS(MySQL) - DBとして。開発環境ではMySQLのコンテナを利用
- Amazon S3 - アップロードされた画像の保存先として
- Amazon ElastiCache(Redis) - セッションの保存。開発環境ではRedisのコンテナを利用
- Amazon SES - メール送信
- Amazon SQS - チャットやメール送信のキューとして
- Amazon IVS, MediaLive, MediaPackage - 動画配信
- Sentry - エラートラッキング

### Dreamkast UI

Repository: https://github.com/cloudnativedaysjp/dreamkast-ui/

#### これは何？


#### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

#### 依存しているサービス


### Dreamkast UI

Repository: https://github.com/cloudnativedaysjp/dreamkast-ui/

#### これは何？


#### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

#### 依存しているサービス




### Dreamkast UI

Repository: https://github.com/cloudnativedaysjp/dreamkast-ui/

#### これは何？


#### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

#### 依存しているサービス



### Dreamkast UI

Repository: https://github.com/cloudnativedaysjp/dreamkast-ui/

#### これは何？


#### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

#### 依存しているサービス



### Dreamkast UI

Repository: https://github.com/cloudnativedaysjp/dreamkast-ui/

#### これは何？


#### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

#### 依存しているサービス

