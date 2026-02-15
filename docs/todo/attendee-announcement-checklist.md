# 参加者向けアナウンス機能（大量配信対応）チェックリスト

- [ ] 送信管理カラム追加（`send_status`, 集計系）
- [ ] `announcement_deliveries` と `email_suppressions` を追加
- [ ] バッチ送信ジョブを実装
- [ ] SESイベント取り込み（SNS→SQS）を実装
- [ ] 管理画面で送信状況を表示
- [ ] SES設定（Configuration Set / イベント通知）をTerraformで作成
- [ ] 送信レートの調整（`ATTENDEE_ANNOUNCEMENT_BATCH_SIZE` / `..._INTERVAL_SECONDS`）
