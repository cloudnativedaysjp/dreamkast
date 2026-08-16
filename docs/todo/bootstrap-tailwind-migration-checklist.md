# Bootstrap → Tailwind CSS 移行チェックリスト

関連 Issue: #2572 (Epic), #2564 (admin 画面優先対応)

## Phase 1: 基盤準備（管理画面から開始）

### 完了
- [x] Tailwind CSS v3 系 (`tailwindcss@^3.4.17`) を導入
- [x] `@tailwindcss/forms` plugin を追加
- [x] `postcss-loader` を webpack の SCSS パイプラインに組み込み
- [x] `tailwind.config.js` を作成（`prefix: 'tw-'`, `preflight: false`）
- [x] admin 画面を Tailwind 化（`admin-*` コンポーネント）

## Phase 2: 公開画面への基盤拡張

### 完了
- [x] `important` を `#admin` から `#wrapper` に変更し、全画面で utility を有効化
- [x] `content` paths を `app/views/**` 全体に拡大
- [x] 全画面共通バンドル `application_tailwind.scss` を追加
- [x] 公開画面コンポーネント（`dk-btn-*`, `dk-input`, `dk-card`, `dk-table`, `dk-alert`, `dk-container`）を定義
- [x] 全 layout（`application` / `cnk` / `no_headers`）で Tailwind を読み込み
- [x] CNDW2026 の webpack エントリと `cndw2026.scss` を追加

## Phase 3: 共有クローム

### 完了
- [x] イベントヘッダー / CNK ヘッダーを Tailwind + Stimulus (`navbar`) に置換
- [x] ログインメニューを Bootstrap dropdown から Tailwind メニューに置換
- [x] フッターを共通 partial 化して Tailwind 化
- [x] flash / toast / modal を Bootstrap JS 依存から外す
- [x] `_navbar.scss` を新しいヘッダー構造向けに更新

## Phase 4: アプリ系画面

### 完了
- [x] 登壇者ダッシュボード（show / profile / sessions カード）
- [x] 参加者ダッシュボード（レイアウト・アラート・ボタン）
- [x] 参加登録フォーム（new / edit ラッパー）
- [x] トーク一覧 / トーク詳細のレイアウトと CTA
- [x] プロポーザル一覧
- [x] スタンプラリー一覧とチェックインモーダル
- [x] home / privacy / coc / エラーページ / 準備中ページ

### 完了（フォーム）
- [x] 参加登録フォーム本体（`profiles/_form.html.erb`）の `form-control` 置換
- [x] 登壇者エントリーフォーム（`speaker_dashboard/speakers/_form*.html.erb` / `_talk_fields.html.erb`）
- [x] 公開プロフィールフォーム
- [x] 招待・受理フォーム（共同スピーカー / キーノート / スポンサー担当者 / スポンサー登壇者）
- [x] スポンサーダッシュボードのフォーム（担当者・セッション・招待）

### 残課題
- [ ] スポンサーダッシュボードの一覧・ナビ・カード一式
- [ ] タイムテーブル本体（イベント固有グリッド SCSS が残る）
- [ ] 配信トラック画面（`tracks/index`）

## Phase 5: イベントトップ

### 完了
- [x] CNDW2026 トップの Bootstrap グリッド / ユーティリティを Tailwind 化
- [x] 汎用 `event/show` の主要セクション
- [x] Sponsors / 開催概要 partial

### 残課題
- [ ] CNDW2025 / CNDS2025 / CNK / 過去イベントトップの同様置換
- [ ] イベント固有 SCSS（`#masthead`, `.page-section`, timetable grid）の Tailwind 移植
- [ ] `sponsor_logo_class` 以外に残る Bootstrap 幅クラスの洗い出し

## Phase 6: 最終移行・クリーンアップ

- [ ] 残ビューから `container` / `row` / `col-*` / `btn` / `form-control` を除去
- [ ] Bootstrap JS（`bootstrap_custom.js`）の削除
- [ ] イベント SCSS からの `@import '~bootstrap/scss/bootstrap'` 削除
- [ ] `prefix: 'tw-'` を外してプレーンな Tailwind に揃える
- [ ] `corePlugins.preflight` を有効化
- [ ] 未使用 CSS / `application-bootstrap.css` の削除
- [ ] 実ブラウザでの表示確認（ヘッダー、ダッシュボード、CNDW2026 トップ）
- [ ] PR レビュー

## 注意事項

- `postcss.config.js` (ルート) は `yarn build:css` (postcss CLI) 専用。webpack 側では `config: false` で読まない。
- Bootstrap はまだイベント SCSS から読み込んでいる。utility の見た目は `tw-` prefix で衝突を避けている。
- ヘッダーのモバイルメニューとユーザーメニューは Stimulus `navbar` コントローラで開閉する。
- モーダル / トーストは Bootstrap JS に依存しない。
