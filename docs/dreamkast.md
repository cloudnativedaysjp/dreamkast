Dreamkast
=========

<div align="center">
<img src="images/dreamkast.png" width="300">
</div>

Repository: https://github.com/cloudnativedaysjp/dreamkast/

### これは何？

Ruby on Railsで書かれたDreamkast platformの中核となるコンポーネント。


### 機能

- カンファレンス
  - カンファレンスのブランドサイト
  - 複数のカンファレンスを扱うことができる
  - カンファレンスに関するステータスを管理できる
    - 参加登録中、開催中、終了、アーカイブ
    - Proposalエントリーの有効・無効
    - 参加申し込みの有効・無効
    - タイムテーブルの表示・非表示
    - スポンサーの表示・非表示

- 登壇者
  - Call for Proposals
    - プロフィール登録
    - Proposalの登録（複数登録可能）
    - (admin)各Proposalの採択・非採択を選択する
    - (admin) 採択結果の公開
    - 公開時には応募者にメール通知する
  - 登壇者用のダッシュボード

- カンファレンス参加者
  - 各カンファレンスに参加登録する
  - 視聴予定セッションを登録する
    - タイムテーブル
    - (admin) 各セッションの日時・トラックを指定してタイムテーブルを作成する
    - セッション情報提供
  - (admin) 参加者へのアナウンス

- スポンサー
  - スポンサー名、URL、ロゴなどをカンファレンスのトップページやイベント当日の配信画面に表示する
  - スポンサー用のダッシュボードからスポンサーセッションが登録できる

- イベント当日
  - 複数トラック
    - 任意の数のトラックを用意可能
    - 各トラック毎に個別に配信できる
    - トラックの切り替えをスムーズに行うことがで着る
  - ライブ配信、もしくは事前録画動画配信
    - 配信はIVSを使用
    - 各セッションをMediaLiveを使って録画、セッション終了後にアーカイブ動画として即公開
  - チャット・QA
    - 各セッション毎にチャットルームが用意されており、参加者・登壇者がコミュニケーションできる
    - テキスト投稿、複数種類の絵文字投稿が可能
    - 特定のメッセージを親としてスレッドを作れる
    - 登壇者の投稿は登壇者とわかるように目立つ見た目になる
    - 質問かどうかを指定でき、質問の場合は目立つ見た目になる。また、質問のみ表示するように表示切り替えができる
- APIの提供

### どこで動いているか

- EKS(Kubernetes)

Manifest: https://github.com/cloudnativedaysjp/dreamkast-infra/tree/main/manifests/app/dreamkast

### 依存しているサービス

- EKS(Kubernetes) - 実行環境として
- Auth0 - 認証認可
- Amazon RDS(MySQL) - DBとして。開発環境ではMySQLのコンテナを利用
- Amazon S3 - アップロードされた画像の保存先として
- Amazon ElastiCache(Redis) - セッションの保存。開発環境ではRedisのコンテナを利用
- Amazon SES - メール送信
- Amazon SQS - チャットやメール送信のキューとして
- Amazon IVS, MediaLive, MediaPackage - 動画配信
- Sentry - エラートラッキング
- Karte - 利用者トラッキング