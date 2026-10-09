# ADR-004: dreamkast-weaverの機能をdreamkast本体に取り込む

ステータス: 提案。2026-10-09のローカルコード調査に基づくロードマップ。

調査対象: dreamkast（main）、dreamkast-ui、dreamkast-weaver `d173d04`、dreamkast-infra、terraform。本番DBの中身、Prometheusのスクレイプ設定、DNSの管理場所は未確認。本書ではコードで確認できた事実と推奨する変更を区別する。

## 背景

dreamkast-weaver（以下weaver、`https://dkw.cloudnativedays.jp`）は、ライブ視聴者数の記録・集計などを担うGoのGraphQLサーバー。名前の由来であるServiceWeaverはメンテナンスが終了したが、weaverからの依存は2025-02に除去済み（weaver `2d5e88c`）。現在はgqlgen + chi + sqlcの通常のHTTPサーバーとして、ECS Fargateで単独のサービスとして動いている。

依存の古さは解消済みだが、この規模の機能のために独立したサービスを維持するコストが割に合っていない。

- AWS費用: 本番は0.25vCPU / 512MB / 1タスク（ARM64）。ALBは本体と共有でリスナールール1本。金額は月数ドル〜十ドル程度と見込む（概算で、請求は未確認）
- 運用コスト: リポジトリ、CI、ECR、ecspressoのprod / stg / reviewapp定義、terraform（IAM・SG・TG・リスナールール・ECR・GitHub ActionsのAssumeRole）、seamanのリリース設定、warm-upワークフロー、Renovateの追従、`dkw`ドメイン

削減効果の中心はAWS費用ではなく運用コストと、次に述べる認証の欠落の解消にある。

## 現状から分かったこと

### 使われている機能

GraphQLの9操作の呼び出し元をdreamkast / dreamkast-uiで確認した。

| 操作 | 呼び出し元 | 判定 |
| --- | --- | --- |
| `viewTrack`（mutation） | dreamkast-ui `useViewerCount.ts`（30秒ごと）、dreamkast `talk_logger_controller.js`（60秒ごと、`trackName: "-"`） | 現役 |
| `viewerCount`（query） | dreamkast-ui `useViewerCount.ts`（60秒ポーリング、`TalkInfo`の「LIVE 👥 n」表示） | 現役 |
| `vote` / `voteCounts` | dreamkast `vote_cfp.js`のみ。ビューの投票ボタンは削除済み | 未使用。dreamkast側は削除済み（PR #2890） |
| `stampOnline` / `stampOnSite` / `stampChallenges` | なし（dreamkast-uiのTrailMapのスタンプはRails APIの`DkUiData`由来） | 未使用 |
| `createViewEvent` / `viewingSlots` | なし | 未使用 |

取り込む対象は`viewTrack`と`viewerCount`の2つに限られる。

### データ

- weaverは`dkui`データベースを使う。現役のテーブルは`track_viewer`（`created_at`、`track_name char(1)`、`profile_id`、`talk_id`）のみ
- dreamkastは`config/database.yml`の`dkui`接続と`DkuiRecord`経由で`TrackViewer`をすでに読んでいる（`OnlineViewerStats`）。DBを移さずに書き込みと集計をRailsへ移せる
- `view_events` / `trailmap_stamps` / `cfp_votes`は未使用機能のテーブル

### weaverの実装上の問題

| 問題 | 内容 | 取り込み時の扱い |
| --- | --- | --- |
| 書き込みが無認証 | `viewTrack`はクライアントが送る`profileID`をそのまま保存する。CORSは`https://*` / `http://*`を許可 | 認証済みユーザーからProfileを解決し、入力の`profileID`を受け取らない |
| イベントで絞り込まない | `viewerCount(confName)`は引数を無視し、全イベントの直近60秒の視聴者を数える | 指定イベントのトークに絞って集計する |
| トラック名をクライアントが決める | `trackName`は`A`〜`F`か`-`（アーカイブ）の1文字で、クライアントの申告どおり保存される | `talk_id`からサーバー側でトラックを決める |
| 集計値がプロセス内キャッシュ | 30秒ごとに集計してメモリに保持。複数タスクにすると値がずれうる | `Rails.cache`等の共有キャッシュにする |

### 負荷

ライブ視聴中のクライアント1つあたり、書き込みが30秒に1回、読み取りが60秒に1回。視聴者数をNとすると、約N/30 + N/60 req/s。N = 3,000で約150 req/s（うち書き込み100）。書き込みは1行のINSERTで、読み取りはキャッシュから返すため、Pumaで処理できる規模と見込む。ただしイベント当日のタスク数・DBコネクション数は見直す。

## 決定

weaverの`viewTrack` / `viewerCount`をdreamkastのAPIとして実装し、weaverを廃止する。未使用の操作は移植しない。

- DBは当面`dkui`の`track_viewer`をそのまま使う。weaverと新APIが同じテーブルに書くため、クライアントの接続先を切り替えるだけで移行・切り戻しができる
- dreamkast-uiからの呼び出しは`SecuredPublicApi`（Bearer）で認証する。dreamkastの視聴ページ（`talk_logger`）からはRailsのセッションで認証する
- GraphQLはやめてREST APIにする。dreamkast-uiのApollo Clientはweaver専用なので、移行後に`@apollo/client`とgraphql-codegenを撤去できる

### API案

| メソッド | パス | 認証 | 内容 |
| --- | --- | --- | --- |
| POST | `/api/v1/talks/:talk_id/viewing` | Bearer | 視聴を1回記録。トラック名はトークから決める |
| GET | `/api/v1/events/:event_abbr/viewer_counts` | 不要 | トラックごとの直近60秒のユニーク視聴者数。結果は30秒キャッシュ |
| POST | `/:event/talks/:id/viewing`（画面用） | セッション + CSRF | `talk_logger`用。処理は上と共通 |

パス名・レスポンス形式は実装時に既存API（`schemas/swagger.yml`）に合わせて確定する。

## ロードマップ

### フェーズ0: 棚卸しと不要機能の削除（済）

- [x] GraphQL各操作の呼び出し元の確認（上表）
- [x] dreamkastからCFP投票（`vote_cfp.js`）を削除（PR #2890）

### フェーズ1: dreamkastにAPIを実装する

- [ ] `TrackViewer`に書き込みを追加（`created_at`はミリ秒精度。主キー`(created_at, profile_id)`の重複はエラーにせず無視する）
- [ ] 視聴記録API・視聴者数APIを実装し、`schemas/swagger.yml`に追加
- [ ] 視聴者数の集計をイベント単位にし、`Rails.cache`でキャッシュ
- [ ] 視聴記録の頻度制限（同一Profileからの過剰な書き込みを捨てる）
- [ ] request specで認証・イベント絞り込み・トラック決定を確認

### フェーズ2: 呼び出し元を切り替える

- [ ] dreamkastの`talk_logger_controller.js`を新APIに切り替え、`ApplicationHelper#weaver_query_url`と`DREAMKAST_WEAVER_ADDR`を削除
- [ ] dreamkast-uiの`useViewerCount.ts`をRTK Query（`baseApi`、Bearer付き）に置き換え
- [ ] dreamkast-uiから`@apollo/client`、graphql-codegen、`src/__generated__`、`NEXT_PUBLIC_WEAVER_URL`を削除

切り替えはstgで確認してから本番に出す。イベント開催の直前・開催中には切り替えない。weaverと同じテーブルを使うため、問題があればクライアントの接続先を戻すだけで切り戻せる。

### フェーズ3: weaverを撤去する

切り替え後、1イベント分の運用でweaverへのアクセスがないことを確認してから行う。

- [ ] dreamkast-infra: `ecspresso/{prod,stg}/dreamkast-weaver`、`ecspresso/base/dreamkast-weaver.libsonnet`、`ecspresso/reviewapps/template-weaver`、各`const.libsonnet`の`dkWeaver` / `dreamkast_weaver`、`warm-up.yml`、seamanの`config.yaml`
- [ ] dreamkast / dreamkast-uiのタスク定義から`dkWeaverEndpoint`
- [ ] terraform: `dreamkast_infra/{prod,stg,dev}`のIAMロール・SG・ターゲットグループ・リスナールール、`ecr`のリポジトリ、`github_actions_assume_aws_role`の対象
- [ ] `dkw.cloudnativedays.jp` / `dkw.dev.cloudnativedays.jp`のDNSレコード
- [ ] dreamkast-weaverリポジトリをアーカイブ

### フェーズ4: データの整理（任意）

- [ ] `view_events` / `trailmap_stamps` / `cfp_votes`をエクスポートして保管し、削除する
- [ ] `track_viewer`の保持期間を決め、古い行を消すタスクを用意する（視聴者1人あたり30秒ごとに1行増える）
- [ ] `track_viewer`を`dkui`からdreamkastの主DBへ移すか判断する。移す場合は`DkuiRecord`と`dkui`接続を撤去できる

## 未確認事項

- 本番でdreamkastの`dkui`接続がweaverと同じRDSを指しているか。`DKUI_MYSQL_*`はタスク定義になく、`MYSQL_HOST`等にフォールバックしている。`OnlineViewerStats`は接続エラーを握りつぶすため、動作中かどうかをログで確認する
- weaverが出すPrometheusメトリクス`dkw_viewer_count`の利用状況。dreamkast-infraの`dashboards/{cndt2023,cndf2023,cnds2024}-main.json`は旧名`dkw_dkui_viewer_count`を参照しており、現在の名前を使うダッシュボードは見当たらない。本番のotelcolサイドカーも無効で、スクレイプされていない可能性が高い。必要なら`dreamkast_exporter`に同等のメトリクスを追加する
- `dkw`のDNSレコードの管理場所（terraformにはALBのホスト名条件のみで、レコード定義は見当たらない）
- 次回イベントの日程と、切り替えを入れられる期間
