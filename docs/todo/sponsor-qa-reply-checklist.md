# スポンサー Q&A 回答機能 実装チェックリスト

スポンサー登壇者(Speaker)以外のスポンサー担当者(SponsorContact)も、視聴ページの SessionQA とスポンサーダッシュボードから Q&A に回答できるようにする。

## 設計方針

- (a) 表示名: SponsorContact が回答した場合は **スポンサー名** を表示。Speaker が回答した場合は従来どおり Speaker 名を表示。
- (b) スキーマ: `session_question_answers` に `sponsor_contact_id` を追加。`speaker_id` と排他(どちらか一方が必須)。

## バックエンド (Rails)

- [ ] マイグレーション追加: `session_question_answers.sponsor_contact_id` (nullable, index, FK to sponsor_contacts)
- [ ] `SessionQuestionAnswer` モデル
  - [ ] `belongs_to :speaker, optional: true`
  - [ ] `belongs_to :sponsor_contact, optional: true`
  - [ ] バリデーション: `speaker_id` と `sponsor_contact_id` のいずれか一方のみ必須(排他)
  - [ ] 表示名アクセサ(例: `answerer_display_name`)で Speaker 名 / Sponsor 名を返す
- [ ] `Api::V1::SessionQuestionAnswersController`
  - [ ] スポンサー担当者からの回答も受け付けられるよう認可を拡張
  - [ ] 「該当 Talk の sponsor に紐づく SponsorContact」を回答者として許可
  - [ ] `verify_speaker` 相当のロジックを「Speaker か SponsorContact か」で分岐
  - [ ] レスポンス JSON に表示名と `answerer_type` を含める
- [ ] スポンサーダッシュボード側のコントローラ/ルート
  - [ ] `sponsor_dashboards/session_questions` のような Q&A 一覧/回答画面を追加
  - [ ] `secured_sponsor` で SponsorContact 認証
  - [ ] そのスポンサーの Talk(SponsorSession 含む)に紐づく質問だけ閲覧/回答可
- [ ] RSpec
  - [ ] モデルバリデーション(排他、必須)
  - [ ] API: SponsorContact での回答可、無関係なスポンサー担当者は不可、Speaker は従来どおり可
  - [ ] スポンサーダッシュボードのリクエストスペック

## フロントエンド (dreamkast-ui)

- [ ] SessionQA で回答フォームの表示条件を拡張: `isSpeaker || isSponsorContactOfTalk`
- [ ] スポンサー担当者判定: profile or 別 API から「自分が回答可能な Talk」を取得
- [ ] 回答表示: API から返る `answerer_type` / 表示名を使用(SponsorContact 回答はスポンサー名で表示)
- [ ] スポンサーダッシュボード(該当画面があれば)に Q&A タブ追加。なければ Rails 側で完結

## 仕上げ

- [ ] `bundle exec rspec` 通過
- [ ] `bundle exec rubocop --autocorrect-all` 通過
- [ ] 動作確認: スポンサー担当者でログインし、担当スポンサーの Talk の質問に回答 → 視聴ページ側でスポンサー名表示を確認
