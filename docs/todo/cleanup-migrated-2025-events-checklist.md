# CNDS2025 / CNDW2025 / CNK migrated 化に伴うクリーンアップ

CNDS2025・CNDW2025・CNK の `conference_status` を `migrated` にしたことで、
これらのイベント固有の画面・アセット・分岐は到達不能になった。
（`Secured#redirect_to_website` により migrated なカンファレンスの全ページが
`https://cloudnativedays.jp/<abbr>` へリダイレクトされるため）

前例: `8376f206 Remove cndt2023, cnds2024, cndw2024` / `d43f7f55 Delete unused files`

## 1. アセット削除

- [x] `app/assets/images/cnds2025/`
- [x] `app/assets/images/cndw2025/`
- [x] `app/assets/images/cnk/`

## 2. JavaScript / SCSS 削除

- [x] `app/javascript/packs/{cnds2025,cndw2025,cnk}.js`
- [x] `app/javascript/stylesheets/{cnds2025,cndw2025,cnk}.scss`
- [x] `app/javascript/stylesheets/{cnds2025,cndw2025,cnk}/`
- [x] `webpack.config.js` の `cnds2025` / `cndw2025` / `cnk` エントリー削除

## 3. ビュー削除

- [x] `app/views/event/{cnds2025,cndw2025,cnk}_show.html.erb`
- [x] `app/views/contents/{cnds2025,cndw2025}_hands_on.html.erb`
- [x] `app/views/contents/{cnds2025,cndw2025}/_projects.html.erb`
- [x] `app/views/timetable/_timetable_cnds2025.erb`
- [x] `app/views/timetable/_timetable_cndw2025.html.erb`
- [x] `app/views/timetable/_timetable_cnk.html.erb`
- [x] `app/views/layouts/cnk.html.erb` / `app/views/layouts/_cnk_header.html.erb`

## 4. `abbr == 'cnk'` 分岐の削除

- [x] `app/controllers/event_controller.rb`（website へのリダイレクト分岐）
- [x] `app/models/conference.rb#twitter_hashtag`
- [x] `lib/tasks/post_number_of_registrants_to_slack.rake`（2箇所）
- [x] `app/views/attendee_dashboards/show.html.erb`（バナー・シェア文言・配信スケジュール・Blogリンク）
- [x] `app/views/speaker_dashboard/speakers/guidance.html.erb`
- [x] `app/views/keynote_speaker_accepts/show.html.erb`（2箇所）
- [x] `app/views/speaker_invitation_accepts/invite.html.erb`（2箇所）
- [x] `app/views/sponsor_speaker_invite_accepts/invite.html.erb`
- [x] `app/views/sponsor_contact_invite_accepts/invite.html.erb`
- [x] `app/views/profiles/new.html.erb`

## 5. イベント固有 rake タスク削除

- [x] `lib/tasks/add_talks_for_cndw2025_intermission.rake`
- [x] `lib/tasks/add_talks_for_cnk.rake`
- [x] `lib/tasks/generate_lead_cndw2025.rake`
- [x] `lib/tasks/recovery_checkin_stg.rake`（cndw2025 固定の一時復旧タスク）

`lib/tasks/generate_lead_cnk.rake` は `CONFERENCE_ABBR` で汎用化されているため残す。

## 6. 検証

- [x] `bundle exec rubocop --autocorrect-all`
- [x] `bundle exec rspec`
- [x] `yarn build`（webpack エントリー削除後のビルド確認）

## 今回は対象外（別途要判断）

- `app/middlewares/dreamkast_exporter.rb` の `CONFERENCE_ID = 15`（CNK 固定）。
  CFP 状況の Prometheus メトリクス。削除ではなく CNDW2026 への差し替えが必要。
- `app/views/timetable/_timetable_cndw2026.html.erb` は `_timetable_cnk.html.erb` の
  完全なコピーで、懇親会リンクが `https://eventregist.com/e/cnk_party` のまま。
  ローカル変数名も `cnk_track_labels` のまま。
- `app/views/speaker_dashboard/speakers/_guidance_section_1.html.erb` の
  過去セッション参照リンク（`event.cloudnativedays.jp/{cndw2025,cnds2025}/timetables`）は
  リダイレクト経由で到達できるため残置。website の URL へ差し替えるかは要判断。
- `db/csv/{cnds2025,cnk}/` と `db/fixtures/*/{01_proposal_item_configs,03_sponsors}.rb` は
  過去イベント分をすべて残す運用のため対象外。
