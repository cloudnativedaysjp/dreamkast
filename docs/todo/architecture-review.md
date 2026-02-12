# Dreamkast アーキテクチャ現状分析と方針提言

## 1. 現状の構造

```
┌─────────────────────────────────────────────────────┐
│                  Nginx (port 8080)                    │
│  /:event/ui/* → Next.js   それ以外 → Rails           │
│  /api/v1/profile/*/point, /talks/*/vote → SAM        │
└──────────┬──────────────────────┬────────────────────┘
           │                      │
    ┌──────▼──────┐       ┌──────▼──────┐
    │ Rails(3000) │       │ Next.js     │
    │             │◄──────│ (3001)      │
    │ - Admin UI  │ API   │ dreamkast-ui│
    │ - 参加者登録│ v1    │ - 視聴画面  │
    │ - 登壇者管理│       └─────────────┘
    │ - スポンサー│
    │ - タイムテーブル
    │ - API v1    │
    │ - ActionCable│
    │ - バックグラウンドジョブ│
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │ MySQL + Redis│
    │ S3, SQS, etc│
    └─────────────┘
```

### コンポーネント別の役割

| コンポーネント | 技術 | 担当範囲 |
|---|---|---|
| Rails モノリス | Rails 7 + Turbo/Stimulus + Webpack | Admin画面、参加者登録、登壇者/スポンサーダッシュボード、タイムテーブル、API v1 |
| Next.js (dreamkast-ui) | Next.js (別リポジトリ) | 視聴画面（ライブ配信中のメインUI） |
| API v1 | Rails内 (14コントローラ) | Next.jsおよび外部連携向けJSON API |
| Admin | Rails内 (28コントローラ) | イベント管理、コンテンツ管理、AWS基盤操作 |

### API v1 が提供しているエンドポイント

- **読み取り専用（認証不要）**: events, talks, speakers, proposals, tracks, streamings, sponsors
- **認証必要**: my_profile, chat_messages, video_registration, talks更新(on_air制御)
- **Admin専用**: check_in_events, check_in_talks, print_node_printers

### Railsビューが担当している画面

- 参加者登録（プロフィール作成・編集）
- 登壇者ダッシュボード（CFP、登壇者情報管理、動画登録）
- スポンサーダッシュボード（担当者管理、セッション管理）
- Admin管理画面全般
- タイムテーブル表示
- セッション一覧・詳細
- 各種静的コンテンツページ

---

## 2. 現状の課題

### 2.1 APIとViewの「中途半端な分離」は実は問題ではない

コードを精査した結果、**APIコントローラとViewコントローラの間には実質的な重複が少ない**。

- `Api::V1::TalksController` → シンプルなJSONレスポンス（index/show/update）
- `TalksController` → CFP結果の表示制御、動画公開判定など、ビュー固有のロジックが大量

両者はそもそも異なる目的を果たしている。APIは「Next.jsにデータを供給する」、Viewコントローラは「Rails画面の表示・フォーム処理をする」。これを無理に統合するメリットはない。

### 2.2 本当の問題: ビジネスロジックのコントローラ肥大化

最も改善が必要なのはAPI分離ではなく、**コントローラにビジネスロジックが集中している点**。

例: `TalksController` の `display_video?` メソッド (84-98行目):
```ruby
def display_video?(talk)
  if (talk.conference.closed? && logged_in?) || (talk.conference.opened? && logged_in?) || talk.conference.archived?
    if talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
      if talk.proposal_items.empty?
        false
      else
        talk.allowed_showing_video? && talk.archived?
      end
    else
      (talk.video_published && talk.video.present? && talk.archived?)
    end
  else
    false
  end
end
```

このロジックはコントローラの責務ではなく、モデルまたはドメインサービスに属すべき。

例: `Api::V1::TalksController#update` の on_air制御ロジック (25-52行目):
```ruby
def update
  @talk = Talk.find(params[:id])
  conference = @talk.conference
  body = JSON.parse(request.body.read, { symbolize_names: true })
  # ... 他のtalkのon_airを全部falseにしてから自分をtrueにする
  # ... ActionCableでブロードキャスト
end
```

トランザクション管理とブロードキャストがコントローラに直接書かれている。

### 2.3 認証ロジックの二重実装

`current_user_model` が `ApplicationController` と `SecuredPublicApi` の両方に**ほぼ同じ実装**で存在する。

**ApplicationController (38-46行目)**:
```ruby
def current_user_model
  return nil unless current_user
  symbolized_current_user = current_user.deep_symbolize_keys
  return nil unless symbolized_current_user[:extra] && symbolized_current_user[:extra][:raw_info] && symbolized_current_user[:extra][:raw_info][:sub]
  @current_user_model ||= User.find_or_create_by_auth0_info(...)
end
```

**SecuredPublicApi (52-60行目)**:
```ruby
def current_user_model
  return nil unless @current_user
  symbolized_current_user = @current_user.deep_symbolize_keys
  return nil unless symbolized_current_user[:extra] && symbolized_current_user[:extra][:raw_info] && symbolized_current_user[:extra][:raw_info][:sub]
  @current_user_model ||= User.find_or_create_by_auth0_info(...)
end
```

唯一の差は `current_user` vs `@current_user` の参照元（セッション vs JWTクレーム）。

### 2.4 イベント固有コードの散在

- Webpack設定にイベントごとのエントリポイント（cnk, cnds2025, cndw2025, cndo2021 ...）
- ビューの中に `event_view` ヘルパーでイベント別テンプレートを動的に選択
- `EventController#show` にcnk固有のリダイレクト処理がハードコード
- `TalksController#index` にcndt2020/cndo2021固有のフィルタ条件

---

## 3. 方針提言

### 結論: 「無理にAPI化しない」は正しい。改善すべきはAPI分離ではなく内部構造。

```
優先度: 高 ──────────────────────────────────────── 低
  ビジネスロジック    認証の統一    イベント固有     完全API化
  のモデル/サービス                 コードの整理     (やらない)
  への移動
```

### 3.1 [推奨] ビジネスロジックをコントローラから抽出する

**対象**: 判定ロジック、トランザクション処理、副作用（メール送信、ブロードキャスト）

**方針**: Railsの既存パターンを活用し、過度な抽象化は避ける

- 判定ロジック → **モデルメソッドに移動**（Talkモデルに `display_video?(user)` など）
- 複数モデルにまたがるトランザクション → **Serviceオブジェクト**（例: `TalkOnAirService`）
- コントローラはルーティング・パラメータ処理・レスポンス生成のみに限定

**効果**:
- APIコントローラとViewコントローラがロジックを共有しやすくなる
- テストがモデル/サービス単体で書ける
- 新しいフロントエンドを追加しても同じロジックを使い回せる

### 3.2 [推奨] 認証の抽象化を統一する

`current_user` の構造体（Hash）が、セッション由来でもJWT由来でも**同じ形状**になるように設計されている（`:info`, `:extra`, `:raw_info`）。これを活かして:

- `CurrentUserResolver` のようなモジュールに `current_user_model` を一箇所にまとめる
- セッションかJWTかの判定は認証Concernが行い、解決後のユーザーオブジェクトは共通で扱う

### 3.3 [任意] Admin画面はRailsのままで問題ない

Admin画面をSPA化する動機はない:
- 利用者はイベント運営者のみ（少数）
- CRUD操作が中心でUXの要求が低い
- Rails + Turbo/Stimulusで十分対応可能
- 28コントローラ分の管理APIを新規に作る工数に見合わない

### 3.4 [任意] 参加者登録・ダッシュボードもRailsのままでよい

- フォーム処理はサーバーサイドレンダリングが素直
- バリデーション・エラー表示がRailsの得意領域
- Next.jsに移行しても体験の改善が限定的

### 3.5 [注意] 完全API化は避ける

完全API化のコストと得られるもの:

| 項目 | コスト | 得られるもの |
|---|---|---|
| Admin画面のAPI化 | 28コントローラ分のAPI新規実装 + フロントエンド実装 | ほぼ変わらないUX |
| 参加者登録のAPI化 | 複雑なフォームのクライアントサイドバリデーション | 若干のUX向上 |
| 登壇者/スポンサーのAPI化 | 認証・認可のAPI対応 | ほぼ変わらないUX |
| APIの保守 | バージョニング、後方互換性の維持 | フロントエンドの柔軟性 |

**視聴画面（Next.js）が既に分離されている時点で、最も重要なUX要件は満たされている。**
残りのページは「カンファレンス管理のための業務ツール」であり、API-first にする利点は薄い。

---

## 4. 具体的な改善例

### 例1: TalkのOn Air制御をServiceに移動

現状 (`Api::V1::TalksController#update`):
```ruby
# コントローラにトランザクション管理とブロードキャストが直接記述
def update
  @talk = Talk.find(params[:id])
  conference = @talk.conference
  body = JSON.parse(request.body.read, { symbolize_names: true })
  if body[:on_air].nil?
    render_400
  else
    if body[:on_air]
      @current_on_air_videos = Video.includes(talk: :conference).where(...)
      ActiveRecord::Base.transaction do
        @current_on_air_videos.each { |video| video.update!(on_air: false) }
        @talk.video.update!(on_air: true)
      end
    else
      @talk.video.update!(on_air: false)
    end
    ActionCable.server.broadcast("on_air_#{conference.abbr}", Video.on_air_v2(conference.id))
    render(json: { message: 'OK' }, status: 200)
  end
end
```

改善案:
```ruby
# app/services/talk_on_air_service.rb
class TalkOnAirService
  def initialize(talk)
    @talk = talk
    @conference = talk.conference
  end

  def start
    ActiveRecord::Base.transaction do
      Video.where(talks: { conference_id: @conference.id }, on_air: true)
           .includes(talk: :conference)
           .update_all(on_air: false)
      @talk.video.update!(on_air: true)
    end
    broadcast_on_air_status
  end

  def stop
    @talk.video.update!(on_air: false)
    broadcast_on_air_status
  end

  private

  def broadcast_on_air_status
    ActionCable.server.broadcast("on_air_#{@conference.abbr}", Video.on_air_v2(@conference.id))
  end
end

# コントローラは薄くなる
def update
  @talk = Talk.find(params[:id])
  body = JSON.parse(request.body.read, { symbolize_names: true })
  return render_400 if body[:on_air].nil?

  service = TalkOnAirService.new(@talk)
  body[:on_air] ? service.start : service.stop
  render(json: { message: 'OK' }, status: 200)
end
```

### 例2: 動画表示判定をモデルに移動

現状 (`TalksController`にhelper_methodとして定義):
```ruby
def display_video?(talk)
  if (talk.conference.closed? && logged_in?) || ...
    # 複雑な条件分岐
  end
end
```

改善案:
```ruby
# app/models/talk.rb
class Talk < ApplicationRecord
  def display_video?(logged_in:)
    return false unless viewable_state?(logged_in:)
    allowed_showing_video? && archived?
  end

  def viewable_state?(logged_in:)
    conference.archived? || ((conference.closed? || conference.opened?) && logged_in)
  end
end
```

### 例3: current_user_model の統一

```ruby
# app/controllers/concerns/current_user_resolver.rb
module CurrentUserResolver
  extend ActiveSupport::Concern

  def current_user_model
    return nil unless current_user_hash
    sub = current_user_hash.dig(:extra, :raw_info, :sub) || current_user_hash.dig(:extra, :raw_info, 'sub')
    return nil unless sub
    @current_user_model ||= User.find_or_create_by_auth0_info(
      sub: sub,
      email: current_user_hash.dig(:info, :email)
    )
  end

  private

  # セッション由来でもJWT由来でも同じ形状のHashを返す
  def current_user_hash
    @current_user&.deep_symbolize_keys
  end
end
```

---

## 5. まとめ

| 方針 | 優先度 | 理由 |
|---|---|---|
| ビジネスロジックをモデル/サービスに移動 | **高** | テスト容易性・再利用性の向上。API/View共通で使える |
| 認証ロジックの統一 | **中** | 二重実装の解消。バグのリスク低減 |
| イベント固有ハードコードの整理 | **低** | 可読性の向上。ただし実害は小さい |
| Admin/ダッシュボードのAPI化 | **不要** | コスト対効果が悪い |
| 完全なAPI/フロントエンド分離 | **不要** | 視聴画面は既に分離済み。残りはRailsが最適 |

**「API化の中途半端さ」は見かけほど問題ではない。視聴画面が分離された時点で最も重要な分離は完了している。改善すべきはAPI境界ではなく、コントローラ内部のロジック配置。**
