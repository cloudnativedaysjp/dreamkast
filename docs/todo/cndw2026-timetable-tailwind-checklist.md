# CNDW2026 タイムテーブル Tailwind 化・4トラック対応チェックリスト

## 背景
- `_timetable_cndw2026.html.erb` は CNK のタイムテーブルを複製したもので、`timetable-modern` 系クラスに依存していた。
- CNK 削除時（548750e1）に `cnk/_timetable.scss` ごとスタイルが消え、表示が崩れていた。
- トラック見出し・開始時刻（10:00 固定）・懇親会/クロージング枠など CNK 固有の値がハードコードされ、3トラック前提だった。

## タスク
- [x] グリッド位置計算をビューから `TimetableHelper` に切り出す（1分 = 1行、休憩は圧縮、トラック数は可変）
- [x] `_timetable_cndw2026.html.erb` を Tailwind ユーティリティで書き直す
  - [x] トラック数を `conference.tracks` から決める（CNDW2026 は 4 トラック）
  - [x] 時刻軸・トラック見出し（スクロール追従）・日付ジャンプリンク
  - [x] lg 未満は時刻ごとのリスト表示
  - [x] セッション選択状態を `:has(:checked)` で表示し、既存の `timetable.js` の排他制御を維持
  - [x] CNK 固有のハードコード（トラック名・Keynote カテゴリ ID・懇親会・クロージング）を除去
- [x] 送信フッターを Tailwind 化（CNDW2026 用に partial 内へ。旧イベント共通の `_timetable_footer` は据え置き）
- [x] ヘルパーの spec と CNDW2026 タイムテーブルの request spec を追加
- [x] rspec / rubocop を通す
- [x] ブラウザで表示確認（デスクトップ 4 列・選択・ホバー展開・見出し追従・モバイル幅）
- [x] 開発用ダミーデータ `db/csv/cndw2026` を cndw2024 の CSV から作り、`00_seeds.rb` で取り込む
- [x] 未ログイン時に残席が表示される問題を修正（GuestProfile の `attend_offline?` が常に true）
- [x] Day1 の懇親会・Day2 のクロージングを登録対象外の固定表示として追加
- [x] PC 表示で、どのトラックにもセッションがない時間帯（休憩）を縮めて空白をなくす

## 残課題
- [ ] CNDW2026 トップ（`event/cndw2026_show.html.erb`）の Sessions 欄は旧グリッド SCSS と CNDW2025 由来の休憩時間ハードコードのまま。
      本 partial のグリッドを共通化して置き換えると、`cndw2026/_timetable.scss` の `section.timetable` を削除できる。
