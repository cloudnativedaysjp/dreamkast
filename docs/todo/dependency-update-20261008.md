# Gem・npm依存関係の互換性を保った更新

- [x] 現在の依存関係、実行環境、CIの検証手順を確認する。
- [x] 既存の制約とメジャーバージョンを維持してGemを更新する。
- [x] npmパッケージを互換性のある範囲で更新し、Yarnのロックファイルを生成する。
- [x] 依存関係の再現性、RSpec、RuboCop、JavaScriptテスト、アセットビルドを確認する。
- [x] 更新内容と検証結果、保留理由を記録する。

作業開始時点で変更済みの `devbox.lock` は今回の更新対象に含めない。

## 更新方針と内容

Gemは `bundle update --all --patch --strict` で更新した。既存Gemのメジャー・マイナー番号を維持していることもロックファイルの比較で確認した。Gemfileの制約、Rails、Ruby、Bundlerは維持する。

npmは既存の範囲指定内、完全固定されたパッケージは同一マイナー系列のパッチ版に限定して17件を更新した。公開から24時間以上経過した安定版を選び、Yarnの `npmMinimalAgeGate` と `enableScripts: false` を維持した。`@testing-library/jest-dom` 6.10.0のpeer dependencyを満たすため、開発依存に `@testing-library/dom` 10系を追加した。

主な更新は以下のとおり。更新前のバージョンはロックファイルで実際に使われていたものを記載する。

| パッケージ | 更新前 | 更新後 |
| --- | --- | --- |
| mysql2 | 0.5.6 | 0.5.7 |
| rack | 3.1.21 | 3.1.22 |
| oauth2 | 2.0.12 | 2.0.25 |
| solid_cable | 4.0.0 | 4.0.2 |
| rspec-rails | 8.0.1 | 8.0.4 |
| rubocop | 1.86.0 | 1.86.2 |
| @rails/actioncable・@rails/activestorage | 8.1.200 | 8.1.400 |
| @rails/ujs | 7.1.2 | 7.1.600 |
| cropperjs | 1.6.2 | 1.6.3 |
| video.js | 8.23.4 | 8.23.9 |
| webpack | 5.104.1 | 5.111.1 |
| sass | 1.97.3 | 1.105.1 |
| postcss | 8.5.6 | 8.5.29 |

## 検証

devboxのRuby 4.0.5、Node.js 22.14.0、Yarn 4.14.1を使用した。

- `BUNDLE_FROZEN=true bundle install --local`、`bundle check`: 成功。
- `yarn install --immutable`: 成功。
- `bundle exec rubocop`: 489ファイル、違反なし。
- `yarn test --runInBand`: 20件成功。
- `yarn build`、`yarn build:css`: 成功。
- `RAILS_ENV=production NODE_ENV=production SECRET_KEY_BASE=dependency-update-test DB_ADAPTER=nulldb DREAMKAST_NAMESPACE=dreamkast AWS_EC2_METADATA_DISABLED=true bundle exec rails assets:precompile`: 成功。
- `RAILS_ENV=test MYSQL_PASSWORD='' DATABASE_PORT=13316 AWS_EC2_METADATA_DISABLED=true bundle exec rspec`: 1109件、失敗0件、既存のpending 2件。一時ディレクトリに用意したMySQL 8.4.7（127.0.0.1:13316）に `rails db:prepare` でテストDBを作成して実行した。

## mainとのコンフリクト解消（2026-10-09）

main側でRails 8.1への更新（#2887）と一部npmパッケージの更新が先に入ったため、以下の手順で解消した。

- `Gemfile.lock` と `yarn.lock` はmainの内容を採用し、その上で `bundle update --all --patch --strict` と `yarn install` を再実行した（Rails 8.1.4を維持）。
- `package.json` は本ブランチの範囲指定に、mainで追加された `resolutions`（`postcss-selector-parser`）を加えた。`@testing-library/jest-dom` はmainで6.9.1に固定されていたが、peer dependencyの `@testing-library/dom` を追加済みのため `^6.10.0` を採用した。
- rubocop 1.86.2で `spec/requests/security_hardening_spec.rb` に `Layout/MultilineMethodCallIndentation` 違反が出たため自動修正した。
- 検証: `yarn install --immutable`、`yarn test`（20件成功）、`bundle exec rubocop`（違反なし）、`yarn build`・`yarn build:css`、`bundle exec rspec`（1172件、失敗0件、pending 2件）。

## 保留した更新と警告

- Gemのマイナー・メジャー更新、npmのメジャー更新は今回の対象外。Rails、Sentry、OpenTelemetry、Uppy、Jest、Tailwind CSSなどの系列を維持した。
- Uppyのcore 5系に対してfile-input・informer・progress-barがcore 4系を要求する警告は更新前から存在する。該当パッケージのバージョンは維持した。解消にはアップローダーの移行と操作確認が必要。
- Sassの非推奨構文・廃止済みの `mixed-decls` 警告とWebpackのバンドルサイズ警告は残るが、開発・本番ビルドは成功した。

更新方法は[Bundlerの更新ガイド](https://bundler.io/guides/updating_gems.html)と[Yarnの公式ドキュメント](https://yarnpkg.com/cli/up)を参照した。
