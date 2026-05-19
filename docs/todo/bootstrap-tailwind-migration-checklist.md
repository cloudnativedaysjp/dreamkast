# Bootstrap → Tailwind CSS 移行チェックリスト

関連 Issue: #2572 (Epic), #2564 (admin 画面優先対応)

## Phase 1: 基盤準備（管理画面から開始）

### 完了
- [x] Tailwind CSS v3 系 (`tailwindcss@^3.4.17`) を `yarn add -D` で導入
- [x] `@tailwindcss/forms` plugin を追加（フォーム要素の素直なリセット用）
- [x] `postcss-loader@^8.1.1` を追加し webpack の SCSS パイプラインに組み込み
- [x] `tailwind.config.js` を作成
  - `prefix: 'tw-'` で全 utility に `tw-` プレフィックス付与（名前衝突回避）
  - `important: '#admin'` で `<div id="admin">` 配下にスコープ
  - `corePlugins.preflight: false` で global reset を無効化
  - `content` paths を `app/views/admin/**` 等に限定
  - `theme.extend.colors` に `cndt-blue`, `cndt-green`, `admin-sidebar` 系を定義
  - `safelist` でブランドカラーを常時生成（スモークテスト兼用）
- [x] `app/javascript/stylesheets/admin_tailwind.scss` を作成（`@tailwind base/components/utilities`）
- [x] `webpack.config.js` に `admin_tailwind` エントリと postcss-loader（inline 設定、`config: false`）を追加
- [x] `app/views/layouts/{application,cnk,no_headers}.html.erb` の `<head>` で `controller_path.start_with?('admin')` の条件付きで `stylesheet_link_tag 'admin_tailwind'` を読み込み
- [x] `yarn build` 成功・`app/assets/builds/admin_tailwind.css` 出力確認
- [x] 出力に `#admin .tw-bg-cndt-blue { ... }` 等が含まれることを確認

### 残課題（Phase 1 範囲内）
- [ ] dev サーバ起動して admin 画面を実ブラウザで確認（既存表示崩れがないこと）
- [ ] PR を出してレビュー（admin 画面のみ影響範囲）

## Phase 2 以降の方針

- Phase 2 のコンポーネント置換は #2564 のスコープで実施
- 置換例:
  - `<div class="container-fluid right-pain">` →
    `<div class="tw-flex-1 tw-p-6 tw-bg-gray-50">` のように tw- prefix 付きで段階的に置換
- `app/javascript/stylesheets/_admin.scss` の独自 CSS は段階的に Tailwind の utility / `@layer components` に移植
- Phase 5（Bootstrap 完全撤去）で `prefix: 'tw-'` を外してプレーンな Tailwind に揃える

## 注意事項

- `postcss.config.js` (ルート) は `yarn build:css` (postcss CLI) 専用。`postcss-import` 等を要求するため webpack 側では `config: false` で読まないようにしている。
- Tailwind が SCSS の中で動くのは `postcss-loader` を `sass-loader` の後段（CSS 出力後）に通しているため。
- 既存 `application-bootstrap.css` ビルド系（cssbundling-rails install の名残）は本 Phase では触らない。
