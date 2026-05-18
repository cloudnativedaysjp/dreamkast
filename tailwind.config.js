/** @type {import('tailwindcss').Config} */
// Bootstrap との共存方針 (Phase 1):
//   - preflight (グローバル CSS reset) を無効化して Bootstrap のスタイルを壊さない
//   - important セレクタ '#admin' で全 utility を admin スコープに限定する
//     (admin/_layout.html.erb の <div id="admin"> 以下でのみ Tailwind が効く)
//   - prefix 'tw-' で名前衝突を防止する
//     例: Bootstrap の .p-4 (1.5rem) と Tailwind の .p-4 (1rem) はサイズが異なる。
//     Bootstrap を完全撤去する Phase 5 でこの prefix は外す予定。
module.exports = {
  prefix: 'tw-',
  important: '#admin',
  corePlugins: {
    preflight: false,
  },
  content: [
    './app/views/admin/**/*.html.erb',
    './app/views/admin.html.erb',
    './app/views/layouts/**/*.html.erb',
    './app/helpers/admin/**/*.rb',
    './app/javascript/packs/admin/**/*.js',
  ],
  // デザインシステムのブランドカラーは利用箇所が増えるまで safelist で常に生成
  // (Phase 1 のスモークテストも兼ねる)
  safelist: [
    'tw-bg-cndt-blue',
    'tw-bg-cndt-green',
    'tw-text-cndt-blue',
    'tw-text-cndt-green',
  ],
  theme: {
    extend: {
      colors: {
        // CloudNative Days ブランドカラー
        'cndt-blue': '#1e40af',
        'cndt-green': '#059669',
        // admin 既存スタイル (#999/#333) と揃えるためのトークン
        'admin-sidebar': '#999999',
        'admin-sidebar-hover': '#ffffff',
        'admin-sidebar-active': '#333333',
        'admin-bg': '#ffffff',
      },
      spacing: {
        sidebar: '250px',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
};
