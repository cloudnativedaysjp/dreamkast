# セキュリティ修正PRのCI修復

- [x] PR #2887の失敗ログを確認する
- [x] Rails 8.1対応のBulletへ更新し、開発環境の読み込みを確認する
- [x] テスト準備全体のRAILS_ENVをtestに統一する
- [x] Dockerfileの推奨パッケージ抑制・非root実行を設定する
- [x] Trivyの対象からインストール済み依存のサンプルを除外する
- [x] ローカルで該当手順・lint・監査を検証する
- [x] PRへpushし、失敗していたCIとSecurity auditの成功を確認する

検証結果: RSpec 1,166件・失敗0・既存pending 2件、Rubocop 497ファイル・指摘なし、Bundler Audit該当なし。CIと同じTrivy 0.69.3で3つのDockerfileのHigh/Critical指摘0件。test環境でDB準備とアセット生成に成功し、migration後のschema差分もなし。Rails 8.1.4とBullet 8.2.0の開発環境読み込みを確認。

GitHub Actions: 修正コミット `f829a66a` の [CI](https://github.com/cloudnativedaysjp/dreamkast/actions/runs/37793250488) と [Security audit](https://github.com/cloudnativedaysjp/dreamkast/actions/runs/37793250329) が成功。ワークフローのlintも成功。
