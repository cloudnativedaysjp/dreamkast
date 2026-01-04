-- MySQL 8.4対応: 認証プラグインを明示的に指定 (caching_sha2_password推奨)
CREATE USER IF NOT EXISTS root@'%' IDENTIFIED WITH caching_sha2_password BY 'root';
GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
