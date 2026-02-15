# 参加者向けアナウンス（SES大量配信）運用ガイド

## 目的
参加者向けアナウンスを大量配信する際のスパム回避・バウンス対応・配信状況の可視化を行う。

## 仕組み概要
- 配信対象を `announcement_deliveries` に分割してバッチ送信
- SESイベント（Bounce/Complaint/Delivery）を SNS -> SQS で受信
- バウンス/苦情は `email_suppressions` に保存し以後の送信を抑制

## 主要テーブル
- `attendee_announcements`
  - `send_status` / `sent_count` / `failed_count` / `bounced_count` / `suppressed_count`
- `announcement_deliveries`
  - 1通単位の配信ログ
- `email_suppressions`
  - バウンス/苦情の抑制リスト

## 環境変数
- `SES_CONFIGURATION_SET`
  - SES の Configuration Set 名
- `SES_EVENT_QUEUE_URL`
  - SESイベントを流し込む SQS URL
- `ATTENDEE_ANNOUNCEMENT_BATCH_SIZE` (optional)
  - 1バッチの送信数（デフォルト 100）
- `ATTENDEE_ANNOUNCEMENT_BATCH_INTERVAL_SECONDS` (optional)
  - バッチ間隔（秒。デフォルト 30）

## SESの設定（Terraform想定）
1. Configuration Set 作成
2. Configuration Set に Event Destination を追加
   - SNS へ `Bounce/Complaint/Delivery` を送信
3. SNS -> SQS サブスクライブ
4. SQS のポリシーで SNS からの publish を許可

## アプリ側の動き
1. 管理画面からアナウンス作成
2. `PrepareAttendeeAnnouncementDeliveriesJob` が対象者を `announcement_deliveries` に展開
3. `SendAttendeeAnnouncementBatchJob` がバッチ送信
4. SESイベントでバウンス/苦情を反映し抑制

## SESイベント受信
SQS から受信したイベントを処理するタスク:

```bash
bundle exec rake ses:poll
```

運用では常駐または定期実行（cron / job runner）を想定。

## 管理画面での確認
`/admin/attendee_announcements` の一覧で送信状況を確認。

- `queued` / `processing` / `sent` / `failed` / `bounced` / `complaint` / `suppressed` を表示

## 注意点
- SESの送信上限はアカウントで異なるため、`ATTENDEE_ANNOUNCEMENT_BATCH_SIZE` と `ATTENDEE_ANNOUNCEMENT_BATCH_INTERVAL_SECONDS` を調整すること。
- `email_suppressions` に登録されたメールアドレスは以後自動的に送信対象から除外される。
