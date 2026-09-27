# HarvestJob の MediaPackage V2 移行チェックリスト

## 方針
- V2 チャネルにアーカイブ切り出し専用の OriginEndpoint を追加する（TS / 6秒セグメント / HLS / startover window 1週間）
- ライブ用 OriginEndpoint（LL-HLS / 1秒セグメント / startover 60秒）は変更しない
- HarvestJob は新テーブル `media_package_v2_harvest_jobs` で管理し、V1 の記録は履歴として残す
- V2 の HarvestJob の記録は作成から15日で AWS 側から消えるため、状態と出力先は DB に保持する

## アプリ
- [x] マイグレーション: `media_package_v2_archive_origin_endpoints` / `media_package_v2_harvest_jobs` を作成
- [x] `MediaPackageV2ArchiveOriginEndpoint` モデル（作成・削除・ポリシー設定・HLS マニフェスト URL）
- [x] アーカイブ用バケット / CloudFront ドメインの対応表を V1 / V2 共通のモジュールに切り出す
- [x] `MediaPackageV2HarvestJob` モデル（作成・状態更新・動画 URL）
- [x] `CreateStreamingAwsResourcesJob` でアーカイブ用エンドポイントを作成
- [x] `DeleteStreamingAwsResourcesJob` でアーカイブ用エンドポイントを削除（HarvestJob の記録は残す）
- [x] `Admin::HarvestJobsController` とビューを V2 に切り替え
- [x] `Talk` / `Conference` / `Streaming` の関連、トラック画面の「録画中」判定を切り替え
- [x] spec を追加・更新
- [x] rubocop / rspec を通す（CI で確認）

## インフラ（別リポジトリ）
- [x] アーカイブ用 S3 バケット（`dreamkast-archive-{prd,stg,dev}-us-west-2`）のポリシーで `mediapackagev2.amazonaws.com` に `s3:PutObject` を許可する（`aws:SourceAccount` 条件付き）
  - terraform#283 で既存ポリシーを import して管理下に置き、3環境とも apply 済み
  - 前提として terraform#284 で prod の ElastiCache Redis の module を削除（Terraform 外で先に消えていたため）
- dreamkast-infra: 変更不要（harvestjob の定期タスクはアプリの rake を実行するだけで、タスクロールには V2 のフルアクセスがある）
- terraform: V2 HarvestJob の失敗通知（EventBridge）は既にある

## rake
- [x] `util:polling_harvest_job_and_update_video` で V2 のジョブをポーリングし、完了時に Video を更新する

## staging で確認
- [ ] 既存の配信にアーカイブ用エンドポイントが作られること（配信リソースの再作成が必要か）
- [ ] HarvestJob を作成し、S3 上の出力ファイルの配置（`destination_path` 配下のマニフェスト名）を確認して `video_url` を合わせる
- [ ] 切り出した動画が CloudFront 経由で再生できること
- [ ] 料金（エンドポイント追加分・startover window 1週間分）を確認

## V1 撤去（別 PR、1イベント運用して問題なければ）
- [ ] MediaLive の V1 向け出力グループを削除
- [ ] `MediaPackageChannel` / `MediaPackageOriginEndpoint` / `MediaPackageParameter` と作成・削除処理を削除
- [ ] `MediaPackageHarvestJob` と V1 SDK（`aws-sdk-mediapackage`）の扱いを決める
