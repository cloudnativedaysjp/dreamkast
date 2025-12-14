# ADR-002: 認証情報とロール情報の分離リファクタリング

## ステータス
提案中

## 作成日
2025-01-XX

## 背景

現在、Dreamkastアプリケーションでは認証情報（`sub`と`email`）が複数のテーブル（Profile, Speaker, SponsorContact, AdminProfile）に分散して保存されています。これにより以下の問題が発生しています：

### 現在の問題点
- `sub`と`email`がProfile, Speaker, SponsorContact, AdminProfileの4つのテーブルに分散
- 同じ認証情報が複数テーブルに重複して保存されている
- 1人のユーザーが複数のロールを持てるが、データの整合性が保証されていない
- ログイン情報の取得ロジックが各コントローラーに散在（11箇所）
- カンファレンス毎に異なるロール情報を持つ必要があるが、認証情報とロール情報が混在している

## 決定事項

ログイン情報（`sub`, `email`）を`users`テーブルに一元管理し、Profile/Speaker/SponsorContact/AdminProfileは`user_id`で参照する構造に変更する。これにより、認証情報とロール情報を明確に分離し、1人のユーザーが複数のカンファレンスで異なるロールを持つことができるようになる。

## 目標構造

```
users (新規)
  - id
  - sub (unique, not null) - カンファレンスに依存しない認証情報
  - email (not null) - カンファレンスに依存しない認証情報
  - created_at, updated_at

profiles
  - user_id (新規追加, foreign_key)
  - conference_id (既存) - カンファレンス毎に異なる参加者情報
  - sub (段階的に削除)
  - email (段階的に削除)
  - ...その他のフィールド
  - unique index: [user_id, conference_id]

speakers
  - user_id (新規追加, foreign_key)
  - conference_id (既存) - カンファレンス毎に異なるスピーカー情報
  - sub (段階的に削除)
  - email (段階的に削除)
  - ...その他のフィールド

sponsor_contacts
  - user_id (新規追加, foreign_key)
  - conference_id (既存) - カンファレンス毎に異なるスポンサー担当者情報
  - sponsor_id (既存)
  - sub (段階的に削除)
  - email (段階的に削除)
  - ...その他のフィールド

admin_profiles
  - user_id (新規追加, foreign_key)
  - conference_id (既存) - カンファレンス毎に異なる管理者情報
  - sub (段階的に削除)
  - email (段階的に削除)
  - ...その他のフィールド
```

### 重要な設計ポイント
- Userはカンファレンスに依存しないグローバルな認証情報（sub, email）を管理
- 各ロール（Profile, Speaker, SponsorContact, AdminProfile）は`user_id` + `conference_id`の組み合わせでカンファレンス毎に異なるデータを保持
- 1人のユーザー（同じsub）が複数のカンファレンスで異なるロールを持つことができる

## 実装計画

各フェーズは1つのPRとして実装する。

### Phase 1: データベース構造の準備、データ移行、アプリケーション層の更新

#### データベース構造の準備とデータ移行
- [x] `app/models/user.rb`を作成
  - `has_many :profiles`
  - `has_many :speakers`
  - `has_many :sponsor_contacts`
  - `has_many :admin_profiles`
  - `validates :sub, presence: true, uniqueness: true`
  - `validates :email, presence: true`
- [x] `db/migrate/YYYYMMDDHHMMSS_create_users_and_migrate_data.rb`を作成（1つのマイグレーションファイル、1トランザクション内で実施）
  - `users`テーブルを作成
    - `sub` (string, unique, not null)
    - `email` (string, not null)
    - インデックス: `sub`にunique index
  - 各ロールテーブルに`user_id`カラムを追加（null許可）
    - `profiles`テーブル: `user_id`カラムを追加
    - `speakers`テーブル: `user_id`カラムを追加
    - `sponsor_contacts`テーブル: `user_id`カラムを追加
    - `admin_profiles`テーブル: `user_id`カラムを追加
  - データ移行を実行（同じマイグレーションファイル内で）
    - 既存のProfile, Speaker, SponsorContact, AdminProfileから`sub`と`email`を抽出
    - 同じ`sub`を持つレコードを統合してUserを作成（1つのsub = 1つのUser）
    - 各ロールテーブルの`user_id`を設定（`user_id` + `conference_id`の組み合わせで各カンファレンス毎のデータを保持）
  - `user_id`にnot null制約を追加
    - `change_column_null :profiles, :user_id, false`
    - `change_column_null :speakers, :user_id, false`
    - `change_column_null :sponsor_contacts, :user_id, false`
    - `change_column_null :admin_profiles, :user_id, false`
  - 外部キー制約を追加
    - `add_foreign_key :profiles, :users`
    - `add_foreign_key :speakers, :users`
    - `add_foreign_key :sponsor_contacts, :users`
    - `add_foreign_key :admin_profiles, :users`
  - インデックスを追加
    - `add_index :profiles, [:user_id, :conference_id], unique: true`
  - すべての処理を1つのトランザクション内で実行し、エラー時はロールバック

#### モデル層とサービス層の更新
- [x] `app/models/profile.rb`: `belongs_to :user`を追加
- [x] `app/models/speaker.rb`: `belongs_to :user`を追加
- [x] `app/models/sponsor_contact.rb`: `belongs_to :user`を追加
- [x] `app/models/admin_profile.rb`: `belongs_to :user`を追加
- [x] `sub`と`email`へのアクセスを`user.sub`と`user.email`に変更するメソッドを追加（後方互換性のため）
- [x] `app/models/profile.rb`: `sub_and_email_must_be_unique_in_a_conference`を`user_id` + `conference_id`ベースに変更
  - `validates :user_id, uniqueness: { scope: :conference_id }`を追加
  - 既存の`sub_and_email_must_be_unique_in_a_conference`バリデーションは段階的に削除
- [x] `app/models/speaker.rb`: 必要に応じて同様のバリデーションを追加
- [x] `app/models/sponsor_contact.rb`: 必要に応じて同様のバリデーションを追加
- [x] `app/models/admin_profile.rb`: 必要に応じて同様のバリデーションを追加
- [x] `app/models/speaker.rb`: `conference.profiles.where(sub:)`を`conference.profiles.where(user_id: user.id)`に変更（`app/controllers/admin/profiles_controller.rb`で対応済み）
- [x] `app/models/user.rb`に`find_or_create_by_auth0_info(sub:, email:)`メソッドを追加
  - Auth0の情報からUserを取得または作成

#### コントローラー層の更新とテスト
- [ ] `app/controllers/application_controller.rb`
  - `current_user_model`メソッドを追加（Userモデルを返す）
  - `set_profile`, `set_speaker`, `set_sponsor_contact`を`user_id` + `conference_id`ベースに変更
    - `Profile.find_by(user_id: current_user_model.id, conference_id: set_conference.id)`
    - `Speaker.find_by(user_id: current_user_model.id, conference_id: set_conference.id)`
    - `SponsorContact.find_by(user_id: current_user_model.id, conference_id: conference.id)`
- [ ] 以下のコントローラーで`current_user[:extra][:raw_info][:sub]`の使用箇所を`UserService`経由に変更：
  - `app/controllers/profiles_controller.rb`
  - `app/controllers/speaker_dashboard/speakers_controller.rb`
  - `app/controllers/sponsor_dashboards/sponsor_contacts_controller.rb`
  - `app/controllers/sponsor_dashboards/sponsor_speakers_controller.rb`
  - `app/controllers/concerns/secured_admin.rb`
  - `app/controllers/admin_controller.rb`
  - `app/controllers/keynote_speaker_accepts_controller.rb`
- [x] テストコードを新しい構造に対応
- [ ] 既存のテストが全て通過することを確認

### Phase 2: クリーンアップ（後方互換性確保後）

- [ ] すべてのコードが`user_id`ベースに移行したことを確認
- [ ] `sub`と`email`カラムを削除するマイグレーションを作成
- [ ] ただし、既存データの参照が必要な場合は残す

## 技術的考慮事項

### データ整合性
- Userテーブルの`sub`はunique制約により、1つのsub = 1つのUserが保証される
- 各ロールテーブルは`user_id` + `conference_id`の組み合わせでカンファレンス毎のデータを保持
- Profileテーブルには`[user_id, conference_id]`のunique indexを追加し、1ユーザー1カンファレンスにつき1つのProfileを保証

### 後方互換性
- 既存の`sub`カラムは段階的に削除（後方互換性のため）
- `sub`と`email`へのアクセスを`user.sub`と`user.email`に変更するメソッドを追加
- データ移行は本番環境でも安全に実行できるよう、トランザクション内で実行

### パフォーマンス影響
- Userテーブルへの追加クエリが発生する可能性があるが、適切なインデックスにより影響を最小化
- `user_id` + `conference_id`の組み合わせでの検索は既存の`sub` + `conference_id`と同等のパフォーマンス

## 参考資料
- [Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
- [Database Migrations](https://guides.rubyonrails.org/active_record_migrations.html)

## 備考
このリファクタリングは、長期的なアプリケーションの保守性とデータ整合性の向上のために重要である。段階的なアプローチにより、リスクを最小化しながら確実に移行を進める。特に、カンファレンス毎に異なるロール情報を持つ必要がある点を考慮し、`user_id` + `conference_id`の組み合わせで管理する設計とした。

