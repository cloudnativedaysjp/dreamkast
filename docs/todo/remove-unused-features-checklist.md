# 未使用機能の削除チェックリスト

grep による参照確認と git 履歴をもとに「すでに使われていない」と判断したコードを削除する。
前回の `cleanup-migrated-2025-events-checklist.md` の続き。

前提: `migrated` のイベントは `Secured#redirect_to_website` により全ページが外部サイトへ
リダイレクトされるため、そのイベント固有の分岐は到達不能。
ただし本番で確認したところ、cndt2020 / cndo2021 / cicd2021 は migrated ではなく
アーカイブとして `event.cloudnativedays.jp` 上で公開中（2026-10-09 時点）。この3イベント向けのコードは残す。

## 1. 機能単位の削除

### チャット（ADR-003 で廃止済み。dreamkast-ui 側の Chat コンポーネントも未使用）
- [x] `admin/chat` ルート / `app/views/admin/chat.html.erb` / `Admin::ChatsController`
- [x] `api/v1/chat_messages` ルート / コントローラ / jbuilder / swagger 定義
- [x] `ChatMessagePolicy` / `ChatMessage` / `ChatChannel` / `ChatMessageBroadcastJob`
- [x] `app/javascript/packs/chat/*` と webpack エントリー
- [x] exporter の `ChatMessage.counts` 系メトリクス、`Talk#chat_messages` 等の関連
- [x] 関連 spec / factory

### IVS 時代の視聴者数集計
- [x] `ViewerCount` / `lib/tasks/get_and_save_current_attendees.rake`
- [x] exporter の `dreamkast_track_viewer_count` / `dreamkast_talk_viewer_count`
- [x] `app/views/api/v1/tracks/viewer_count.json.jbuilder`

### 旧チェックイン（CheckIn）
- [x] `CheckIn` / `Admin::CheckInsController` / ルート
- [x] `lib/tasks/cleanup_profiles.rake` の参照

### 旧視聴画面の補助アクション
- 〔訂正〕`WaitingChannel` は `Admin::ConferencesController#update` が開催時にブロードキャストしており現役のため残す
- [x] `TracksController#reload` / `#blank` / `tracks/blank.html.erb` / `tracks/blank` ルート

### イベント固有の contents ページ
- [x] どのイベントにもテンプレートがない `job-board` / `community_lt` / `yurucafe` / `stamprally` のルートとアクション、`ContentsController#index`
- 〔訂正〕`discussion` / `hands-on` と `contents/cicd2021_*` / `contents/cndt2020_discussion` は公開中のアーカイブから到達できるため残す

## 2. 壊れていて動いていないコードの削除
- [x] `packs/talks.js` の未定義 `tracker` を呼ぶタイマー、未使用の `tableFilterStripHtml`
- [x] `packs/admin/tracks/tracks_channel.js`（削除済み `update_tracks()` を呼ぶ）
- [x] `app/models/print_node.rb`（gem のモジュールに隠れて読み込まれない）
- [x] `lib/tasks/add_unique_code_to_profile.rake`（存在しない列を参照）
- [x] `lib/tasks/aws.rake` の IVS 関連処理
- [x] `api/v1` の重複した `resources :speakers`
- [x] 重複した `profiles/entry_sheet` ルート
- [x] `speaker_dashboard/video_registrations` ルート（コントローラなし）

## 3. どこからも呼ばれていないコード
- [x] コントローラ: `SponsorController` / `Admin::LinksController` / `SponsorDashboards::SpeakersController` / `Profiles::TalksController#new,#edit,#update,#destroy`
- [x] ビュー: `talks/partial_show/*` の未使用 partial、`proposals/partial_show/_col_sub_pane`、`profiles/sponsors/_microsoft`、`profiles/checkin`、`keynote_speaker_accepts/show`、`sponsor_dashboards/sponsor_dashboards/login`、トップレベルの `sponsor_contact_invites/*`、`layouts/_karte`、`event/_privacy`、`profiles/talks/show`
- [x] policy / concern / helper: `TalkPolicy`、`SecuredBeta`、`BetaHelper#partial_beta_view`、`ApplicationHelper#authenticate`、空の `contents_helper` / `dashboard_helper`、`Admin::TalkTableHelper#alert_type`、AWS ヘルパーの `get_*_from_aws`
- [x] モデル: `Talk::Type`、`TalkCategory.for_cnd/for_pek/for_srek`、`Sponsor#booth_sponsor?`、`Talk#sponsor_keynote?` / `#execution_phase_params`、`TalkType.non_exclusive`、`Profile#gen_calendar_unique_code`、`ProposalItem.select_proposal_items`、`MediaLiveChannel::OutputGroupIvs`
- [x] JS: `app/javascript/channels/`、webpack の `admin_tailwind` エントリー
- [x] `SpeakerMailer#video_uploaded` とビュー
- [x] `bin/test-args.sh`、`bin/spring`、`config/spring.rb`

## 4. 過去イベント固有の残り
- 〔対象外〕cndt2020 / cndo2021 / cicd2021 の event show・timetable・pack・SCSS・画像・abbr 分岐（公開中のアーカイブのため）
- [x] 参照のない画像ディレクトリ（migrated 済みイベントの `app/javascript/images/*`、`app/assets/images/{cnds2024,cndw2024}`、`app/assets/images/sponsors/{cndt2021,cndt2022,cnsec2022,o11y2022}`、古いアイコン類）
  - `sponsors/{cndt2020,cndo2021,cicd2021}` はスポンサーロゴの URL として DB から参照され、公開中のため残す
- [x] 一回限りの rake（cnds2025 用の `rescure_checkin` / `rescure_session`、`migrate_talks_to_proposal_items`）

## 5. 依存関係・設定
- [ ] Gem: `rails_autolink`、`activerecord-nulldb-adapter`、`byebug`、`execjs`、`rexml`、`steep`
- [ ] npm: `popper.js`、`@rails/activestorage`、`file-loader`、`webpack-bundle-analyzer`、`@testing-library/*`
- [ ] 中身が全部コメントの initializer、`new_framework_defaults_7_*.rb`
- [ ] `config/amazon-rds-ca-cert.pem`、`Dockerfile.dev`、ルート直下の不要ファイル
- [ ] Dockerfile / compose / docs の未使用環境変数（`DB_ADAPTER`、`RAILS_LOG_TO_STDOUT`、`CHROME_BIN`、`DREAMKAST_API_ADDR`）

## 6. 検証
- [ ] `bundle exec rubocop --autocorrect-all`
- [ ] `bundle exec rspec`
- [ ] `yarn build`

## 今回は対象外（別途要判断）
- DB テーブル・列の削除（`chat_messages`、`viewer_counts`、`check_ins`、`attendee_announcements*`、`talks.expected_participants/execution_phases`、`videos.video_file_data` など）。
  コード削除のリリース後にマイグレーションを別 PR で行う。
- `KeynoteSession` / `Intermission` / `Session`（STI）。本番 DB に該当 `type` の行が残っていないか確認が必要。
- 動画アップロード経路（`/s3/multipart`、`MultipartUpload`、`VideoFileUploader`、`@uppy/*`）。
- `tracks#index`（開催中は `/ui/` へのリダイレクト入口として使われている可能性）。
- `event#show` / `cndw2026_show`、`links`、`/team`、`contents#o11y`、`api/v1/debug`、録画・PrintNode 印刷・CSS ビルドパイプライン。
- リポジトリ外（infra の cron 等）から呼ばれている可能性のある rake タスク。
