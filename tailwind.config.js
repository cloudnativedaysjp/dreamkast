/** @type {import('tailwindcss').Config} */
// Bootstrap との共存方針 (Phase 2):
//   - preflight (グローバル CSS reset) を無効化して Bootstrap のスタイルを壊さない
//   - important セレクタ '#wrapper' で全 utility をレイアウト配下に限定する
//     (layouts の <div id="wrapper"> 以下。admin の <div id="admin"> もその内側)
//   - prefix 'tw-' で名前衝突を防止する
//     例: Bootstrap の .p-4 (1.5rem) と Tailwind の .p-4 (1rem) はサイズが異なる。
//     Bootstrap を完全撤去する Phase 5 でこの prefix は外す予定。
module.exports = {
  prefix: 'tw-',
  important: '#wrapper',
  corePlugins: {
    preflight: false,
  },
  content: [
    './app/views/**/*.{html,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/packs/**/*.js',
  ],
  // デザインシステムのブランドカラーと、application_tailwind.scss の @layer components で
  // 定義した共通コンポーネントを常に生成する
  safelist: [
    'tw-bg-cndt-blue',
    'tw-bg-cndt-green',
    'tw-text-cndt-blue',
    'tw-text-cndt-green',
    // admin テーブル
    'admin-table',
    'admin-table-card',
    'admin-table-scroll',
    // admin フォーム
    'admin-form-card',
    'admin-form-section',
    'admin-form-label',
    'admin-form-hint',
    'admin-form-required',
    'admin-input',
    'admin-textarea',
    'admin-select',
    'admin-radio',
    'admin-checkbox',
    'admin-btn-primary',
    'admin-btn-secondary',
    'admin-btn-danger',
    // 公開画面共通
    'dk-container',
    'dk-btn-primary',
    'dk-btn-secondary',
    'dk-btn-danger',
    'dk-btn-dark',
    'dk-input',
    'dk-textarea',
    'dk-select',
    'dk-card',
    'dk-table',
    'dk-table-card',
    'dk-alert',
    'dk-alert-info',
    'dk-alert-success',
    'dk-alert-warning',
    'dk-alert-danger',
  ],
  theme: {
    extend: {
      colors: {
        // CloudNative Days ブランドカラー
        'cndt-blue': '#1e40af',
        'cndt-green': '#059669',
        'cndt-navy': '#216a9c',
        'cndt-magenta': '#be4493',
        // admin 既存スタイル (#999/#333) と揃えるためのトークン
        'admin-sidebar': '#999999',
        'admin-sidebar-hover': '#ffffff',
        'admin-sidebar-active': '#333333',
        'admin-bg': '#ffffff',
      },
      spacing: {
        sidebar: '250px',
      },
      maxWidth: {
        'dk-container': '1140px',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
};
