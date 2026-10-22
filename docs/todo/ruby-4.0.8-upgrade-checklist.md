# Ruby 4.0.8 へのアップグレード

- [x] `.ruby-version` を 4.0.8 に更新する。
- [x] Ruby 4.0.8 の公式 Docker イメージが未公開のため、`Dockerfile`・`Dockerfile.dev` で Ruby を自前ビルドする。
- [x] ローカルの Ruby 4.0.8 で RSpec・RuboCop が通ることを確認する。
- [x] `Dockerfile` を linux/amd64 でビルドし、イメージ内の Ruby が 4.0.8（YJIT 有効）であることを確認する。
- [x] `ruby/setup-ruby` が 4.0.8 に未対応のため、CI（`ci.yml`・`trivy.yml`）では一時的に 4.0.5 を使う。
- [ ] `ruby/setup-ruby` が 4.0.8 に対応したら、固定している SHA を更新し、CI の `ruby-version` を `.ruby-version` に戻す。
- [ ] 公式イメージ `ruby:4.0.8` / `ruby:4.0.8-slim` が公開されたら、自前ビルドのステージを削除して公式イメージに戻す。

## 自前ビルドについて

Ruby 4.0.8 は 2026-10-22 にリリースされたが、同日時点では Docker Hub・public.ecr.aws のどちらにも `ruby:4.0.8` イメージが公開されていなかった（4.0 系の最新は 4.0.7）。

そのため、公式イメージの Dockerfile（docker-library/ruby の `4.0/trixie`・`4.0/slim-trixie`）にならって以下のステージを追加した。

- `ruby-build`: `buildpack-deps:trixie` 上で Ruby をソースからビルドし、`DESTDIR=/ruby` にインストールする。ソースの tarball は SHA256 を検証する。YJIT / ZJIT を有効化するため Rust も導入する。
- `ruby`: 公式の `ruby:<version>` 相当。`buildpack-deps:trixie` に `/usr/local` をコピーする。ネイティブ拡張の gem をビルドする `fetch-lib`・`asset-compile` で使う。
- `ruby-slim`: 公式の `ruby:<version>-slim` 相当。`debian:trixie-slim` に、公式 slim イメージと同じ実行時ライブラリを入れて `/usr/local` をコピーする。

自前ビルドの間は Renovate による Ruby イメージの更新提案は届かない。
