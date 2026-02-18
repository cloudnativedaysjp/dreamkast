# アナウンス（SES大量配信）運用ガイド

## 目的
参加者向けアナウンスを大量配信する際のスパム回避・バウンス対応・配信状況の可視化を行う。

## 仕組み概要
- 配信対象を `announcement_deliveries` に分割してバッチ送信
- SESイベント（Bounce/Complaint/Delivery）を SNS -> SQS で受信
- バウンス/苦情は `email_suppressions` に保存し以後の送信を抑制
- 送信レートは ActiveJob のバッチ設定で制御（デフォルト 10通/秒）

## 送信フロー詳細
1. 管理画面からアナウンスを作成
2. `PrepareAnnouncementDeliveriesJob` が対象プロフィールを展開し、`announcement_deliveries` を作成
   - `email_suppressions` に該当するアドレスは `suppressed` として記録
3. `SendAnnouncementBatchJob` が `queued` を一定数ずつ送信
   - 成功: `sent` + `provider_message_id` 付与
   - 失敗: `failed` + `last_error`
4. バッチが完了すると `send_status=completed` に更新

## バウンス/苦情対応フロー詳細
1. SESイベント（Bounce/Complaint/Delivery）が SNS -> SQS に届く
2. `ses:poll` が SQS を読み取り `SesEventProcessor` を実行
3. `email_suppressions` を更新
   - 既存があれば `last_seen_at` を更新
   - 無ければ新規作成（`reason=bounce/complaint`）
4. `announcement_deliveries` のステータスを更新
   - `bounced` / `complaint`
5. 以後の送信時に suppression に該当するメールは送らない

## 主要テーブル
- `announcements`
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
- `ANNOUNCEMENT_BATCH_SIZE` (optional)
  - 1バッチの送信数（デフォルト 10）
- `ANNOUNCEMENT_BATCH_INTERVAL_SECONDS` (optional)
  - バッチ間隔（秒。デフォルト 1）

## レート制御設計（ActiveJob前提）
- ワーカーは **1プロセス** を前提
- 送信レート = `BATCH_SIZE / BATCH_INTERVAL_SECONDS`
- デフォルトは **10通/秒**（10 / 1s）
- SES上限に合わせて環境変数で調整

## SESの設定（Terraform想定）
1. Configuration Set 作成
2. Configuration Set に Event Destination を追加
   - SNS へ `Bounce/Complaint/Delivery` を送信
3. SNS -> SQS サブスクライブ
4. SQS のポリシーで SNS からの publish を許可

## アプリ側の動き
1. 管理画面からアナウンス作成
2. `PrepareAnnouncementDeliveriesJob` が対象者を `announcement_deliveries` に展開
3. `SendAnnouncementBatchJob` がバッチ送信
4. SESイベントでバウンス/苦情を反映し抑制

## SESイベント受信（ActiveJob前提）
ActiveJobワーカーが **生SQSメッセージを処理できない** 前提の場合、  
別途「SESイベントSQS -> ActiveJob」変換プロセスが必要。

SESイベントの取り込みは **ECS Scheduled Task** で `ses:poll` を定期実行する運用とする。

```bash
bundle exec rake ses:poll
```

## 管理画面での確認
`/admin/announcements` の一覧で送信状況を確認。

- `queued` / `processing` / `sent` / `failed` / `bounced` / `complaint` / `suppressed` を表示

## 注意点
- SESの送信上限はアカウントで異なるため、`ANNOUNCEMENT_BATCH_SIZE` と `ANNOUNCEMENT_BATCH_INTERVAL_SECONDS` を調整すること。
- `email_suppressions` に登録されたメールアドレスは以後自動的に送信対象から除外される。
