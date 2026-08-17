# CI用MySQLパフォーマンスチューニングチェックリスト

## 概要
GitHub Actions の CI で起動する MySQL に、耐久性より書き込み性能を優先した設定を適用する。
RSpec は example ごとにトランザクションとテーブルのクリーンアップで大量の書き込みを行うため、
コミットごとの fsync を省くと実行時間が縮む。CI の DB は毎回使い捨てるので、
クラッシュリカバリを考慮する必要がない。

タイミーの技術記事「【GitHub Actions】明日からマネできる CI 高速化テクニック 3 選」
(https://tech.timee.co.jp/entry/2026/06/12/120143) の施策③を取り込んだもの。
同記事の施策①（キャッシュ保存先の S3 移行）は AWS セルフホストランナーが前提のため不適合、
施策②（マイグレーション済み datadir のキャッシュ）は効果が未計測のため見送った。

## 方針
- 対象は **CI のみ**。開発環境の `compose.yaml` には手を入れない
  （ローカルの DB は永続データを持つため、耐久性を落とすべきではない）
- compose の override 機構で分離する: `-f compose.yaml -f compose.ci.yaml`
- 本番環境には絶対に適用しない

## 適用するmysqldオプション

| オプション | 効果 |
|---|---|
| `--innodb-flush-log-at-trx-commit=0` | デフォルト `1` はコミットのたびに REDO ログを fsync する。`0` で書き込みも fsync も毎秒のバッチ処理になる |
| `--skip-log-bin` | MySQL 8.x はバイナリログがデフォルト有効。CI ではレプリケーションを使わないのでログ生成自体を止める。記事の `--sync-binlog=0`（fsync だけ止める）より踏み込んだ設定 |
| `--skip-innodb-doublewrite` | 部分書き込み対策で全ページを2回書く安全機構を無効化し、書き込み I/O を減らす |

## ベースライン

計測対象: main の CI run 31980983075

| ステップ | 所要 |
|---|---|
| 全体 | 3分27秒 |
| Prepare tests (db:create + db:migrate + check_git_diff + assets:precompile) | 56秒 |
| Run tests (RSpec 1083 examples) | 76秒（rspec 本体 68.6秒） |

## タスク

- [x] `compose.ci.yaml` を新規作成し、CI 専用の mysqld オプションを定義する
- [x] `.github/workflows/ci.yml` の `Run database` ステップで override を読ませる
- [x] compose のマージ結果を `docker compose config` で確認する
- [x] CI 上で MySQL が起動し、設定が反映されていることを確認する
- [x] `rake ci:check_git_diff` が引き続き成功すること（`db:migrate` 後に `db/schema.rb` に差分が出ない）
- [x] RSpec 1083 examples が 0 failures であること
- [x] Simplecov のカバレッジが閾値 60 を下回らないこと
- [ ] ベースラインと実行時間を比較し、改善幅を記録する（**サンプル不足で判定保留**）

## 計測結果（暫定）

| run | Prepare tests | Run tests | rspec本体 |
|---|---|---|---|
| main 31980983075 | 56秒 | 76秒 | 68.56秒 |
| main 31980965346 | 42秒 | 63秒 | 未取得 |
| PR 32041688010（本変更） | 60秒 | 69秒 | 61.55秒 |

MySQL は新しいフラグで正常に起動し、テストは 1083 examples / 0 failures、
カバレッジも 67.94% で変化なし。**設定自体は問題なく動作する。**

一方で**効果は確認できていない**。変更なしの main 同士で「Run tests」が
63秒と76秒、13秒ぶれている。この変動幅が、本変更で観測された7秒の短縮より大きい。
`Prepare tests` に至ってはベースラインより遅い側に出ている。
n=1 同士の比較では、改善なのかランナー変動なのか判別できない。

判定には各条件5サンプル程度が必要。それに見合う価値があるかは要検討。

## 注意点

- compose の `command` は**マージではなく上書き**になる。`compose.yaml` 側の
  `--character-set-server` / `--collation-server` を override 側にも書き写している。
  落とすと照合順序が変わりテストが壊れる
- `volumes` は override で指定しないことで `compose.yaml` の定義を引き継ぐ。
  `db/docker-entrypoint-initdb.d/2_create-cable-database.sql` が solid_cable 用の
  `dreamkast_cable` スキーマを作るため、ここは触らない

## 効果が出なかった場合

改善幅が誤差レベル（数秒未満）なら、変更を取り込まず破棄する判断もありうる。
その場合、記事②の datadir キャッシュ検討に進む前に、まず Prepare tests 56秒の内訳
（`db:migrate` と `assets:precompile` の比率）を CI ログのタイムスタンプから計測する。

## スコープ外

- CI ジョブの並列化。現状 `run-test` の単一ジョブで yarn test → rubocop → rspec を
  直列実行している。記事の対象外だが、削減幅は今回の施策より大きい可能性がある
- `/var/lib/mysql` の tmpfs 化。さらに I/O を削れるが OOM リスクがある
