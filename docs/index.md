Dreamkast platform
==================

## Table of content

- [Dreamkast](#dreamkast)
- [Dreamkast UI](#dreamkast-UI)
- [Dreamkast Infra](#dreamkast-infra)
- [Dreamkast Relasebot](#dreamkast-relasebot)
- [Dreamkast Review App Operator](#dreamkast-reveiw-app-operator)
- [Dreamkast API Docs](#dreamkast-api-docs)

## Dreamkast

See [Dreamkast](docs/dreamkast.md)

## Dreamkast UI

Repository: https://github.com/cloudnativedaysjp/dreamkast-ui/

### これは何？

イベント当日に視聴者が動画配信を視聴するためのアプリケーション。Amazon IVSやVimeoの動画を埋め込み、視聴者に提供する。タブによるUIで簡単にトラックを切り替えられる設計が特徴

 Next.jsを使っており、TypeScriptで記述されている。

- IVS/Vimeoの埋め込み(イベントによって使い分ける)
- タブによるセッション切り替え機能
- チャット機能
- スポンサーブース(現状は無効化)

DreamkastとDreamkast UIの前段にはKubernetes上で稼働しているContourがおり、L7ロードバランスされている。/uiにアクセスしたときはDreamkast UIに繋がるようになっている

### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

### 依存しているサービス

- Dreamkast - REST APIでイベントに関する情報を取得。またイベントの切り替えやチャットをWebSocketを使って通信している
- Karte - 利用者トラッキング

## Dreamkast Infra

Repository: https://github.com/cloudnativedaysjp/dreamkast-infra

### これは何？

Dreamkastの各コンポーネントをIaCするリポジトリ。

- Kubernetesマニフェスト
- CloudFormation - AWSリソースの管理
- Terraform - AWS以外のリソースの管理
- Grafana Dashboard

## Dreamkast Releasebot

Repository: https://github.com/cloudnativedaysjp/dreamkast-releasebot

### これは何？

ChatOpsを実現するコンポーネント。Slackで@dreamkast-releasebotを呼び出すことで、各プロダクトをProduction環境にデプロイできる。

言語/Framework: Go / slack-go (RTM)

### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast-releasebot

## Dreamkast Review App Operator

Repository: https://github.com/cloudnativedaysjp/dreamkast-releasebot

### これは何？

GitHubのPull Requestをチェックし、新しいPRが出来たらDreamkastのコンポーネント一式を立ち上げる、KubernetesのOperator。

言語/Framework: Go / Kubebuilder

### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/infra/reviewapp-operator

## Dreamkast API Docs

Repository: https://github.com/cloudnativedaysjp/dreamkast-api-docs

### これは何？

DreamkastのAPIを定義しているドキュメント。Swaggerを利用している

### どこで動いているか

- DocsがKubernetes上で動いている

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast-api-mock/base





