# セキュリティ追加対応（2026-10-09）

security-hardening（#2887）後の追加チェックで見つかった項目への対応。

## 方針
- ストリーミングAPIの `destinationUrl`（RTMP取り込みURL）露出はリスクを理解した上で許容する
- スタンプラリーのチェックインがIDのみで行える点は仕様とする
- Action Cable の接続認証は ADR 003 の脱WebSocket移行で撤去されるため対応しない

## チェックリスト

### 廃止済みチャットの残存コード撤去（ADR 003）
- [x] `ChatChannel`（未認証で `ChatMessage` を作成できる `post` を含む）を削除
- [x] `/:event/admin/chat` ルート・ビュー、未使用の `Admin::ChatsController` を削除
- [x] `chat/index` JSバンドル（`app/javascript/packs/chat`）と webpack エントリを削除
- [x] `ChatMessageBroadcastJob` と `ChatMessage` のbroadcastコールバックを削除
- 対象外: チャットAPI・`ChatMessage` モデル・テーブル・メトリクス（履歴データの保持は ADR 003 で別に扱う）

### プロフィール更新のmass assignment
- [x] `ProfilesController#profile_params` から `:sub` `:email` `:roles` `:conference_id` を除外

### Markdown描画のXSS
- [x] `ApplicationHelper#markdown` の出力をサニタイズし、リンクを安全なスキームに限定

### URLスキーム検証
- [x] `Talk#document_url` を http/https のみに制限（変更時のみ検証し、既存データの保存を妨げない。`http://` のみのプレースホルダー値は許容）
- [x] スピーカー／スポンサーのフォームでエラーを表示
- [x] 既存データ対策として、表示時にも http/https 以外のURLを出力しない

### CSV数式インジェクション
- [x] 管理画面のCSVエクスポート（Talk / Speaker / Profile / 統計）で `= + - @ TAB CR` 始まりのセルをエスケープ
- [x] スポンサー向けリードCSV（`generate_lead_cnk`）も同様にエスケープ

### 仕上げ
- [x] RSpec 追加・実行
- [x] rubocop 実行
