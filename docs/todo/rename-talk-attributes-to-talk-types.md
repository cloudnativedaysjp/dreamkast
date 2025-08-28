# talk_attributes → talk_types リネーム作業チェックリスト

## 概要
`talks_attributes` と `talk_attribute_associations` を `talks_types` と `talk_type_associations` にリネームする。

## 作業チェックリスト

### 1. データベースマイグレーション (4ファイル)

#### マイグレーションファイルのリネームと内容更新
- [ ] `db/migrate/20250812095327_create_talk_attributes.rb` → `20250812095327_create_talk_types.rb`
  - [ ] テーブル名を `talk_types` に変更
  - [ ] インデックス名を適切に更新
  
- [ ] `db/migrate/20250812095352_create_talk_attribute_associations.rb` → `20250812095352_create_talk_type_associations.rb`
  - [ ] テーブル名を `talk_type_associations` に変更
  - [ ] `talk_attribute_id` を `talk_type_id` に変更
  - [ ] インデックス名を `idx_talk_types_unique` に更新
  - [ ] 外部キー制約の参照先を更新

- [ ] `db/migrate/20250812095422_seed_talk_attributes.rb` → `20250812095422_seed_talk_types.rb`
  - [ ] `TalkAttribute` を `TalkType` に変更
  - [ ] メソッド名や変数名を更新

- [ ] `db/migrate/20250812095631_migrate_legacy_session_data.rb`
  - [ ] `TalkAttribute` への参照を `TalkType` に変更
  - [ ] `talk_attribute_associations` への参照を `talk_type_associations` に変更

### 2. モデル (3ファイル)

- [ ] `app/models/talk_attribute.rb` → `app/models/talk_type.rb`
  - [ ] クラス名を `TalkType` に変更
  - [ ] `has_many :talk_attribute_associations` を `has_many :talk_type_associations` に変更
  - [ ] `through: :talk_attribute_associations` を `through: :talk_type_associations` に変更

- [ ] `app/models/talk_attribute_association.rb` → `app/models/talk_type_association.rb`
  - [ ] クラス名を `TalkTypeAssociation` に変更
  - [ ] `belongs_to :talk_attribute` を `belongs_to :talk_type` に変更
  - [ ] バリデーションメソッド内の参照を更新
  - [ ] エラーメッセージ内の `talk_attribute` を `talk_type` に変更
  - [ ] `sync_legacy_fields` メソッド内の参照を更新

- [ ] `app/models/talk.rb`
  - [ ] `has_many :talk_attribute_associations` を `has_many :talk_type_associations` に変更
  - [ ] `has_many :talk_attributes, through:` を `has_many :talk_types, through:` に変更
  - [ ] `validate :validate_talk_attributes_presence` を `validate :validate_talk_types_presence` に変更
  - [ ] `attr_accessor :skip_talk_attributes_validation` を `attr_accessor :skip_talk_types_validation` に変更
  - [ ] スコープ内の `talk_attributes` テーブル参照を `talk_types` に変更
  - [ ] スコープ内の `talk_attribute_associations` を `talk_type_associations` に変更
  - [ ] `with_talk_attribute` スコープを `with_talk_type` に変更
  - [ ] メソッド名の更新:
    - [x] `set_talk_attributes` → `set_talk_types`
    - [ ] `add_talk_attribute` → `add_talk_type`
    - [ ] `remove_talk_attribute` → `remove_talk_type`
    - [ ] `session_attribute_names` → `session_type_names`
    - [ ] `create_or_update_talk_attributes` → `create_or_update_talk_types`
  - [ ] メソッド内部の実装を更新

### 3. サービス (1ファイル)

- [ ] `app/services/talk_attribute_service.rb` → `app/services/talk_type_service.rb`
  - [ ] クラス名を `TalkTypeService` に変更
  - [ ] メソッド名 `assign_attributes` は維持（または `assign_types` に変更を検討）
  - [ ] 内部実装の `TalkAttribute` を `TalkType` に変更
  - [ ] `talk_attribute_associations` を `talk_type_associations` に変更
  - [ ] エラーメッセージを更新

### 4. ヘルパー (3ファイル)

- [ ] `app/helpers/admin/talk_attributes_helper.rb` → `app/helpers/admin/talk_types_helper.rb`
  - [ ] モジュール名を `Admin::TalkTypesHelper` に変更
  - [ ] メソッド内の参照を更新

- [ ] `app/helpers/admin/talks_helper.rb`
  - [ ] `talk_attributes` への参照を `talk_types` に変更

- [ ] `app/helpers/speakers_helper.rb`
  - [ ] 必要に応じて参照を更新

### 5. コントローラー (6ファイル)

- [ ] `app/controllers/admin/talks_controller.rb`
  - [ ] `params[:talk_attributes]` を `params[:talk_types]` に変更
  - [ ] `update_talk_attributes` メソッドを `update_talk_types` に変更
  - [ ] クエリ内の `talk_attributes` テーブル参照を更新

- [ ] `app/controllers/admin/speakers_controller.rb`
  - [ ] クエリ内の `talk_attributes` テーブル参照を更新

- [ ] `app/controllers/speaker_dashboard/speakers_controller.rb`
  - [ ] Strong parameters内の `talk_attributes: []` を `talk_types: []` に変更

- [ ] `app/controllers/sponsor_dashboards/sponsor_sessions_controller.rb`
  - [ ] Strong parameters内の `talk_attributes: []` を `talk_types: []` に変更

- [ ] `app/controllers/sponsor_dashboards/speakers_controller.rb`
  - [ ] 必要に応じて参照を更新

- [ ] `app/controllers/api/v1/proposals_controller.rb`
  - [ ] `includes(talk: :talk_attributes)` を `includes(talk: :talk_types)` に変更
  - [ ] `talk.talk_attributes.pluck(:name)` を `talk.talk_types.pluck(:name)` に変更

- [ ] `app/controllers/proposals_controller.rb`
  - [ ] includesの `:talk_attributes` を `:talk_types` に変更

### 6. ビュー (5ファイル)

- [ ] `app/views/admin/talks/index.html.erb`
  - [ ] フォームフィールド名を更新
  - [ ] `talk_attributes` への参照を `talk_types` に変更

- [ ] `app/views/speaker_dashboard/speakers/_form.html.erb`
  - [ ] フォームフィールド名を更新

- [ ] `app/views/speaker_dashboard/speakers/_talk_fields.html.erb`
  - [ ] フォームフィールド名を更新

- [ ] `app/views/speaker_dashboard/speakers/_session_times.html.erb`
  - [ ] 必要に応じて参照を更新

- [ ] `app/views/speaker_dashboard/speakers/_presentation_method.html.erb`
  - [ ] 必要に応じて参照を更新

### 7. フォーム (2ファイル)

- [ ] `app/forms/speaker_form.rb`
  - [ ] `talk_attributes` への参照を `talk_types` に変更

- [ ] `app/forms/sponsor_session_form.rb`
  - [ ] `talk_attributes` への参照を `talk_types` に変更

### 8. テストファイル (11ファイル)

#### Specファイルのリネーム
- [ ] `spec/models/talk_attribute_spec.rb` → `spec/models/talk_type_spec.rb`
  - [ ] `RSpec.describe TalkAttribute` を `RSpec.describe TalkType` に変更
  - [ ] ファクトリー名を `:talk_attribute` から `:talk_type` に変更

- [ ] `spec/models/talk_attribute_association_spec.rb` → `spec/models/talk_type_association_spec.rb`
  - [ ] `RSpec.describe TalkAttributeAssociation` を `RSpec.describe TalkTypeAssociation` に変更
  - [ ] アソシエーション名を更新

- [ ] `spec/services/talk_attribute_service_spec.rb` → `spec/services/talk_type_service_spec.rb`
  - [ ] `RSpec.describe TalkAttributeService` を `RSpec.describe TalkTypeService` に変更
  - [ ] サービスクラス名を更新

#### ファクトリーファイル
- [ ] `spec/factories/talk_attributes.rb` → `spec/factories/talk_types.rb`
  - [ ] `factory :talk_attribute` を `factory :talk_type` に変更
  - [ ] クラス名を `TalkType` に更新

- [ ] `spec/factories/talks.rb`
  - [ ] 関連するファクトリー定義を更新

#### その他のテストファイル
- [ ] `spec/models/talk_spec.rb`
  - [ ] アソシエーション名を更新
  - [ ] メソッド名を更新

- [ ] `spec/requests/speaker_dashboard/speaker_create_spec.rb`
  - [ ] パラメータ名を更新

- [ ] `spec/requests/sponsor_dashboards/sponsor_create_spec.rb`
  - [ ] パラメータ名を更新

- [ ] `spec/requests/sponsor_dashboards/sponsor_sessions_spec.rb`
  - [ ] パラメータ名を更新

### 9. データベーススキーマ

- [ ] `db/schema.rb`
  - [ ] `create_table "talk_attributes"` を `create_table "talk_types"` に変更
  - [ ] `create_table "talk_attribute_associations"` を `create_table "talk_type_associations"` に変更
  - [ ] カラム名 `talk_attribute_id` を `talk_type_id` に変更
  - [ ] インデックス名を更新
  - [ ] 外部キー制約を更新

### 10. その他

- [ ] `db/helpers.rb`
  - [ ] `TalkAttribute` への参照を `TalkType` に変更

## 動作確認チェックリスト

### 構文チェック
- [x] 主要ファイルの構文チェックが通ること
  - [x] `app/models/talk_type.rb`
  - [x] `app/models/talk_type_association.rb`
  - [x] `app/models/talk.rb`
  - [x] `app/services/talk_type_service.rb`
  - [x] `app/forms/speaker_form.rb`
  - [x] `app/forms/sponsor_session_form.rb`

### テストの実行
- [ ] `bundle exec rspec` が全て成功すること（要bundler環境）
- [ ] 特に以下のテストを重点的に確認:
  - [ ] `spec/models/talk_type_spec.rb`
  - [ ] `spec/models/talk_type_association_spec.rb`
  - [ ] `spec/services/talk_type_service_spec.rb`

### リントの実行
- [ ] `bundle exec rubocop --autocorrect-all` を実行（要bundler環境）
- [ ] エラーや警告がないことを確認

### 手動確認
- [ ] 管理画面でTalkの一覧表示が正常に動作すること
- [ ] Talkの編集画面でタイプの選択が正常に動作すること
- [ ] スピーカーダッシュボードでの登録・編集が正常に動作すること
- [ ] スポンサーダッシュボードでの登録・編集が正常に動作すること

## 注意事項

1. **データベースマイグレーション**
   - 既存のデータがある場合は、データ移行用のマイグレーションが必要
   - 本番環境でのリリース時は、ダウンタイムを考慮する必要がある

2. **APIの互換性**
   - APIレスポンスのフィールド名が変わる可能性があるため、フロントエンドとの調整が必要

3. **キャッシュのクリア**
   - デプロイ後はキャッシュのクリアが必要な場合がある