-- Action Cable (solid_cable) 専用データベースをローカル開発用に作成する。
-- MySQL イメージは MYSQL_DATABASE(=dreamkast) しか自動作成しないため、
-- 別スキーマ dreamkast_cable をここで用意し、アプリ用ユーザーに権限を付与する。
-- （このスクリプトは MySQL データボリュームが空の初回起動時のみ実行される）
CREATE DATABASE IF NOT EXISTS dreamkast_cable
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
GRANT ALL PRIVILEGES ON dreamkast_cable.* TO 'user'@'%';
