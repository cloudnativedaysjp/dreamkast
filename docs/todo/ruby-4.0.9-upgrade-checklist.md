# Ruby 4.0.9 へのアップグレード

- [x] public.ecr.aws に `ruby:4.0.9` / `ruby:4.0.9-slim` イメージがあるか確認する（2026-10-23 時点で未公開。`4.0.8` は公開済み）。
- [x] 公式イメージが未公開のため、`Dockerfile`・`Dockerfile.dev` の自前ビルドを 4.0.9 に更新する。tarball の SHA256 は ruby-lang.org のリリース情報と照合した。
- [x] `.ruby-version` を 4.0.9 に更新する。
- [x] `Dockerfile` の `ruby-slim` ステージまでを linux/amd64 でビルドし、イメージ内の Ruby が 4.0.9（YJIT 有効）であることを確認する。
- [ ] 公式イメージ `ruby:4.0.9` / `ruby:4.0.9-slim` が公開されたら、自前ビルドのステージを削除して公式イメージに戻す。
