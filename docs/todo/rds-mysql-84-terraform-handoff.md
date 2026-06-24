# 引き継ぎ: RDS for MySQL 8.0 → 8.4.9 アップグレード（Terraform 作業）

別セッション（Terraform を管理するリポジトリ）で実施するための引き継ぎ文書。
この文書だけで作業を開始できるよう、背景・確定事項・作業内容・注意点をすべて記載する。

## 1. ゴールと背景
- **現状**: RDS for MySQL **8.0.42**
- **移行先**: MySQL **8.4.9**（LTS）※ チームで決定済み
- **理由 / 期限**: RDS for MySQL 8.0 は **2026-07-31 に標準サポート終了**。以降は有償の RDS Extended Support に自動移行し追加課金が発生する。期限前に 8.4 系へ上げる必要がある。
- 8.4 は MySQL 初の LTS。RDS で選択可能な 8.4 系の最新マイナーが 8.4.9（2026-05 リリース）。
- 8.0.42 → 8.4.9 は中間バージョン不要で**直接アップグレード可**（メジャーアップグレード扱い）。

## 2. すでに完了していること（アプリ側）
アプリ本体リポジトリ `cloudnativedaysjp/dreamkast` 側の対応は **PR #2843** で実施済み。
- ローカル/CI の MySQL を `mysql:8.4.9` に更新
- 8.4 で削除された `--default-authentication-plugin=mysql_native_password` を
  `--mysql-native-password=ON --authentication-policy=mysql_native_password` に置換し、
  **`mysql_native_password` を維持**（mysql2 の接続方式を変えないため）
- アプリのコード/接続設定（mysql2 ~> 0.5.6）は変更不要

→ **この方針に合わせ、RDS 側も `mysql_native_password` を有効化して維持する**こと。
そうすればアプリ側の追加変更は不要で一貫する。

## 3. ⚠️ 最重要: native_password の扱い（手作業必須）
- 現在の RDS(8.0) の既存ユーザ（**マスターユーザ含む**）は `mysql_native_password` で作成されている。
- **RDS 8.4 では `mysql_native_password` がデフォルト無効(OFF)**、既定は `caching_sha2_password` に変わる。
- 何もせず上げると **既存ユーザが認証できず、アプリが DB 接続不可**になる（アップグレードの precheck で弾かれる場合もある）。
- 対策: **8.4 用 DB パラメータグループで `mysql_native_password = 1 (ON)` を設定**してからアップグレードする。
  - これは**静的パラメータ**のため反映には再起動が必要（アップグレード時の再起動で反映）。
- 注意: 既存ユーザはアップグレード後も native 維持されるが、**新規作成ユーザは `caching_sha2_password`** になる。

## 4. Terraform でやること
> リポジトリの実構成に合わせて調整すること。以下は典型的な変更点。

1. **対象 RDS リソースの特定**
   - `aws_db_instance`（または `aws_rds_cluster` / Aurora の場合は別）の `engine = "mysql"` を探す。
   - 現在 `engine_version` が `8.0.42`（または `8.0` 系）になっているはず。

2. **`engine_version` の変更**: `8.0.42` → **`8.4.9`**

3. **8.4 用 DB パラメータグループ**
   - `aws_db_parameter_group`（または Aurora は `aws_rds_cluster_parameter_group`）の
     `family` を `mysql8.0` → **`mysql8.4`** に。
   - **`mysql_native_password = "1"` のパラメータを追加**（apply_method は静的なので `pending-reboot`）。
     ```hcl
     parameter {
       name         = "mysql_native_password"
       value        = "1"
       apply_method = "pending-reboot"
     }
     ```
   - 既存の 8.0 パラメータで 8.4 に存在しない/値が変わったものがないか確認（family 変更で差分が出る）。
   - インスタンス側 `parameter_group_name` をこの 8.4 用グループに向ける。

4. **アップグレード方式の検討**
   - 本番は **Blue/Green Deployment** 推奨（短時間ダウンで切替・ロールバック容易）。
   - Terraform で in-place に `engine_version` を変える場合は `allow_major_version_upgrade = true` が必要。
     ダウンタイム・切り戻し容易性の観点から Blue/Green の方が安全。
   - 方式はチームのリスク許容度に応じて決定すること。

5. **その他確認**
   - `auto_minor_version_upgrade` の挙動
   - スナップショット/バックアップ設定、メンテナンスウィンドウ

## 5. アップグレード手順（実作業の流れ）
1. **pre-checks**: 予約語・非推奨機能・孤立テーブル等の事前チェック（mysqlcheck / AWS の precheck）。
2. 8.4 用パラメータグループを準備（`mysql_native_password=ON` を含む）。
3. ステージング/検証環境で先に実施し、アプリ接続を確認。
4. 本番を Blue/Green で Green(8.4.9) 作成 → 検証 → スイッチオーバー。
5. 切替後の確認 SQL:
   ```sql
   SELECT VERSION();                               -- 8.4.9
   SHOW VARIABLES LIKE 'mysql_native_password';    -- ON
   SELECT user, host, plugin FROM mysql.user;      -- 既存ユーザが native のまま
   ```
6. アプリの接続・主要機能の動作確認 →（任意）旧環境のクリーンアップ。

## 6. ロールバック
- Blue/Green ならスイッチオーバー前は Blue(8.0) がそのまま残るので切り戻し容易。
- 事前にスナップショットを取得しておく。

## 7. 将来的な推奨（今回スコープ外・任意）
- `mysql_native_password` は MySQL 9.x で完全削除予定。落ち着いたら `caching_sha2_password` への移行を推奨。
  ```sql
  ALTER USER 'ユーザ名'@'ホスト' IDENTIFIED WITH caching_sha2_password BY 'パスワード';
  ```
- 移行時はアプリ側（mysql2 + TLS or 公開鍵交換）の動作検証が必要。今回は**当面 native password 維持が最小リスク**。

## 8. 参考リンク
- [Upgrade strategies for Amazon RDS for MySQL 8.0 to 8.4](https://aws.amazon.com/blogs/database/upgrade-strategies-for-amazon-rds-for-mysql-8-0-to-8-4/)
- [Best practices for upgrading Amazon RDS for MySQL 8.0 to 8.4 (prechecks, Blue/Green, rollback)](https://aws.amazon.com/blogs/database/best-practices-for-upgrading-amazon-rds-for-mysql-8-0-to-8-4-with-prechecks-blue-green-and-rollback/)
- [MySQL on Amazon RDS versions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MySQL.Concepts.VersionMgmt.html)
- [RDS: mysql_native_password is deprecated… (re:Post)](https://repost.aws/questions/QUWAfAVNWPT6mECbrJLLisYg/rds-mysql-native-password-is-deprecated-and-will-be-removed-in-a-future-release-please-use-caching-sha2-password-instead)
- アプリ側 PR: cloudnativedaysjp/dreamkast #2843
