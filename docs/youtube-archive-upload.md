# アーカイブ動画の YouTube 自動アップロード & 再生置換

## 目的
セッションのアーカイブ動画を YouTube にアップロードし、視聴ページの再生を YouTube 埋め込みに
置き換える。配信コスト/CDN 負荷の削減と、YouTube プレイヤーによる再生体験・互換性の向上が狙い。

## 仕組み概要
- アーカイブ動画は従来どおり MediaPackage Harvest Job で HLS(.m3u8) として S3 に生成される
- YouTube は HLS を受け付けないため、**AWS MediaConvert で HLS → mp4 へ変換**してからアップロードする
- アップロードは **HarvestJob のポーリングと同様に定期実行の rake タスクで進める**
  （`util:upload_archive_videos_to_youtube`、外部スケジューラ/CronJob から定期実行）
- 変換は時間がかかるため、状態を `videos` テーブルに持たせ、実行のたびに
  「変換開始 → 完了確認 → アップロード」と 1 ステップずつ進める（単一実行で長時間ブロックしない）
- 視聴ページは YouTube 動画があれば埋め込み再生、無ければ従来の video.js(HLS) にフォールバックする
- 管理画面のボタンは個別の手動トリガー / 失敗時の再開用（変換完了〜アップロードは定期タスクが引き継ぐ）

## データモデル
`videos` テーブルに以下のカラムを追加（`db/migrate/20260621000000_add_youtube_columns_to_videos.rb`）。

| カラム | 型 | 用途 |
|---|---|---|
| `youtube_video_id` | string | YouTube 側の動画 ID |
| `youtube_upload_status` | integer (enum) | アップロード状態 |
| `youtube_uploaded_at` | datetime | アップロード完了時刻 |
| `youtube_upload_error` | text | 失敗時のエラー原因 |
| `media_convert_job_id` | string | 進行中の MediaConvert ジョブ ID（完了確認のポーリングに使う） |

- `video_id`（HLS の manifest URL）は変更せず残す。変換のソース兼フォールバック再生に使う。
- `youtube_upload_status` enum（`app/models/video.rb`）:
  `not_uploaded(0) / converting(1) / uploading(2) / uploaded(3) / failed(4)`
- `Video#youtube_available?` … `uploaded?` かつ `youtube_video_id` present のとき true。

## アップロードフロー詳細
処理本体は `Youtube::ArchiveUploader`（`app/services/youtube/archive_uploader.rb`）にあり、
`#process!` が現在の状態を **1 ステップだけ** 進める。戻り値は
`:started` / `:in_progress` / `:uploaded` / `:failed` / `:skipped`。

状態遷移（`youtube_upload_status`）:

1. `not_uploaded`（かつアーカイブ HLS あり）→ **変換開始**
   - 対象 Talk の最新 HarvestJob から HLS の S3 URI を取得（`MediaPackageHarvestJob#s3_manifest_uri`）
   - MediaConvert ジョブを作成（`MediaConvertHelper#create_media_convert_job`）
   - `media_convert_job_id` を保存し `status: converting`（`:started`）
2. `converting` → **完了確認**（`MediaConvertHelper#media_convert_job_status`）
   - 進行中 → 何もせず `:in_progress`
   - `COMPLETE` → **アップロード**へ
     - 出力 mp4 を S3 からローカル一時ファイル（`tmp/youtube_uploads/{video_id}/`）にダウンロード
     - `status: uploading` に更新し、`YoutubeHelper#upload_video_to_youtube` でアップロード
       （メタデータは `Youtube::MetadataBuilder` で生成、privacy デフォルト `public`）
     - `youtube_video_id` を保存し `status: uploaded`、`youtube_uploaded_at` を記録（`:uploaded`）
     - 一時ファイルは `ensure` で必ず削除
   - `ERROR` / `CANCELED` → `status: failed`（`:failed`）
3. 例外時は `status: failed` + `youtube_upload_error` を記録

### 定期実行（メインの起動経路）
- rake タスク `util:upload_archive_videos_to_youtube`
  （`lib/tasks/upload_archive_videos_to_youtube.rake`）を外部スケジューラ/CronJob から定期実行する。
- `Video.youtube_pending`（アーカイブ HLS があり `not_uploaded` か `converting`）を対象に
  `Youtube::ArchiveUploader#process!` を呼ぶ。`util:polling_harvest_job_and_update_video` と同じ流儀。
- 完了（`:uploaded`）・失敗（`:failed`）時に Slack 通知する。

### 手動トリガー（管理画面）
- `/{event}/admin/videos` の各行のボタン → `Admin::VideosController#upload_to_youtube`
  → `UploadArchiveToYoutubeJob.perform_later`（`process!` を 1 回呼ぶ）。
- `failed` の動画は定期タスクの対象外なので、手動トリガー時に `not_uploaded` へリセットして再開する。

## 再生フロー詳細
`app/views/talks/show.html.erb` の視聴可否ゲート `display_video?(@talk)` の内側で分岐する。

1. `@talk.video&.youtube_available?` が true
   → `talks/partial_show/_talk_video_block_youtube`（youtube-nocookie iframe で埋め込み）
2. それ以外
   → 従来の `talks/partial_show/_talk_video_block_videojs`（HLS を video.js で再生）

視聴可否の判定（公開期間・ログイン状態など）は従来の `display_video?` のまま変更しない。

## メタデータ生成（`Youtube::MetadataBuilder`）
- title: `"{talk.title} - {conference.name}"`（100 文字に切り詰め、`<` `>` を除去）
- description: abstract + 登壇者名 + 資料 URL + カンファレンスリンク
- tags: カンファレンス abbr / カテゴリ名
- category_id: `28`（Science & Technology）

## 設定（環境変数）
秘匿情報は他の外部連携と同様に ENV で管理する（Rails credentials は未使用）。

| 変数 | 用途 |
|---|---|
| `YOUTUBE_CLIENT_ID` / `YOUTUBE_CLIENT_SECRET` / `YOUTUBE_REFRESH_TOKEN` | YouTube Data API の OAuth2 認証 |
| `YOUTUBE_PRIVACY_STATUS` | 公開範囲（任意、デフォルト `public`） |
| `MEDIACONVERT_ROLE_ARN` | MediaConvert ジョブ実行ロール |
| `MEDIACONVERT_ENDPOINT` | MediaConvert エンドポイント（任意、未指定なら SDK が解決） |
| `YOUTUBE_MP4_BUCKET` | 変換後 mp4 の出力先 S3 バケット |
| `AWS_LIVE_STREAM_REGION` | リージョン（既存。MediaConvert/S3 でも利用） |

## 運用上の注意
- OAuth の refresh_token は事前に取得しておく（どの Google アカウント / ブランドチャンネルに
  アップロードするか要決定）。YouTube Data API のアップロードは日次クォータ消費が大きい。
- MediaConvert の IAM ロール / 出力バケットを事前に整備しておく。
- アップロード失敗時は管理画面に「再アップロード」ボタンが表示され、再実行できる。

## 主要ファイル
- モデル: `app/models/video.rb`（enum / `youtube_available?` / `youtube_pending` スコープ）,
  `app/models/media_package_harvest_job.rb`（`s3_manifest_uri`）
- サービス: `app/services/youtube/archive_uploader.rb`（状態遷移の本体）,
  `app/services/youtube/metadata_builder.rb`
- 定期タスク: `lib/tasks/upload_archive_videos_to_youtube.rake`
- ジョブ（手動トリガー）: `app/jobs/upload_archive_to_youtube_job.rb`
- ヘルパー: `app/helpers/youtube_helper.rb`, `app/helpers/media_convert_helper.rb`
- ビュー: `app/views/talks/show.html.erb`,
  `app/views/talks/partial_show/_talk_video_block_youtube.html.erb`,
  `app/views/admin/videos/index.html.erb`
- コントローラ/ルーティング: `app/controllers/admin/videos_controller.rb`, `config/routes.rb`
- マイグレーション: `db/migrate/20260621000000_add_youtube_columns_to_videos.rb`,
  `db/migrate/20260621000001_add_media_convert_job_id_to_videos.rb`

## テスト
- `spec/models/video_spec.rb` … enum / `youtube_available?` / `youtube_pending` スコープ
- `spec/services/youtube/archive_uploader_spec.rb` … 状態遷移（変換開始 / 進行中 / 完了→アップロード / 失敗 / スキップ）
- `spec/services/youtube/metadata_builder_spec.rb` … title のサニタイズ・切り詰め
- `spec/jobs/upload_archive_to_youtube_job_spec.rb` … enqueue / サービスへの委譲
- `spec/requests/admin/videos_spec.rb` … 管理者の enqueue / 未ログインの遮断

外部 API（YouTube）・AWS（MediaConvert）・S3 はメソッド単位でスタブする
（既存 `create_streaming_aws_resources_job_spec.rb` の流儀。WebMock/VCR は未導入）。
