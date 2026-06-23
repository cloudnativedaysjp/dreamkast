# YouTube Data API クォータ拡張審査（Compliance Audit）対応ガイド

## 背景
アーカイブ動画の YouTube アップロード機能では `videos.insert` を使う。
これは 1 回 **1,600 ユニット**で、デフォルトのクォータは **10,000 ユニット/日**
（≒ 1 日 6 本）。イベントの全セッションを短期間で上げるには足りないため、
クォータ拡張が必要になる。拡張には **コンプライアンス監査の通過が必須**。

関連: [youtube-archive-upload.md](youtube-archive-upload.md)（機能本体）

## Dreamkast の用途が審査で有利な理由
- 第三者の YouTube データを扱わない。**自分たちで撮影・権利を持つ登壇動画を、
  自分たちの YouTube チャンネルにアップロードする一次利用**である。
- 再生は実装済みの公式 IFrame プレイヤー（`youtube-nocookie` 埋め込み）で行っており、
  Developer Policies の「公式プレイヤーで再生」「帰属表示を消さない」を既に満たす。

## 審査が見る 2 点
1. **ポリシー準拠**（YouTube API Services 利用規約 / Developer Policies）
2. **要求クォータの妥当性**（必要量を実数で説明できるか。「人気だから」はNG）

## 提出前チェックリスト

| 要件 | 状態 | 対応 |
|---|---|---|
| 公式プレイヤーで再生（オフライン/バックグラウンド/音声単独再生は禁止） | ✅ 済 | `youtube-nocookie` iframe で要件充足 |
| 帰属表示（YouTube ブランド）を消さない | ✅ 済 | iframe が自動表示。ロゴ非表示等の細工をしない |
| プライバシーポリシー（常時アクセス可・YouTube API 利用を明記・Google プライバシーポリシーへのリンク・データ削除の連絡先） | ⚠️ 要追記 | 既存のカンファレンス別ポリシーに YouTube API 利用条項を追加 |
| OAuth 同意画面の設定/（大規模なら）検証 | ⚠️ 要確認 | `youtube.upload` は機微スコープ。自社チャンネルでも同意画面構成が必要 |
| GCP プロジェクト番号 / OAuth Client ID | 用意 | フォーム必須。`API Client = OAuth Client ID` |
| 動作デモ / スクリーンショット | 用意 | 管理画面ボタン→アップロード→再生の流れを見せられると強い |

## フォーム（英語）に貼る用途説明の雛形
数値は実数に置き換えること。

> **What does your API Client do?**
> Dreamkast is the open-source conference management system operated by the
> non-profit CloudNative Days community (https://github.com/cloudnativedaysjp/dreamkast).
> After each conference, we upload **our own session recordings** (talks we filmed
> and own the rights to) from our archive storage to **our own YouTube channel**
> via `videos.insert`, then embed them back on each session page using the official
> YouTube IFrame player. We do **not** access, store, or process other users'
> YouTube data; uploads are first-party content to a single channel owned by us.
>
> **Which API methods do you use?**
> Primarily `videos.insert` (upload). Occasionally `videos.list` / `videos.update`
> to verify or update metadata of videos we uploaded.
>
> **Why do you need additional quota?**
> Each event produces ~150 session recordings. `videos.insert` costs 1,600 units,
> so one event requires ~240,000 units. We run 4–6 events/year and want to publish
> archives within 2–3 days of each event. The default 10,000 units/day (≈6 uploads/day)
> cannot cover this. We request **X units/day**.

## クォータ見積もりの算数（要求値の根拠）
- 1 本 = **1,600 ユニット**
- 例: 1 イベント 150 本 → 240,000 ユニット。2 日で上げるなら **120,000 ユニット/日**
- 余裕を見て **300,000〜1,000,000 ユニット/日**を要求し、上記の算数を添える
- 過大要求は逆効果。年間イベント数 × 本数で正直に積む

## 却下されやすいポイントと回避策
- **用途が曖昧**（"video app" 等）→「自社コンテンツの一次アップロード」と明言
- **根拠なき大量要求** → 必ず 本数 × 1,600 の算数を書く
- **プライバシーポリシー不備** → 公開 URL・YouTube API 明記・Google ポリシーリンク・削除窓口を揃える
- **規約違反の匂い**（再アップロード代行・スクレイピング・独自指標と API データの混同）→ 該当しないと明記

## 申請フロー / 期間
1. [YouTube API Services - Audit and Quota Extension Form](https://support.google.com/youtube/contact/yt_api_form?hl=en) を提出
2. 担当者から連絡。追加情報を求められたら速やかに返答
3. 監査通過後にクォータ付与（数日〜数週間）
4. 過去 12 か月以内に監査済みなら「Audited Developer Requests Form」で追加申請

## 監査なしで運用する代替案
急がないなら、定期タスク `util:upload_archive_videos_to_youtube` で
**1 日数本ずつにペース配分**すればデフォルトクォータ内で回せる。
`quotaExceeded` 時は `youtube_upload_status` を `not_uploaded` のままにして翌日再開。

## 参考リンク
- [Quota and Compliance Audits | YouTube Data API](https://developers.google.com/youtube/v3/guides/quota_and_compliance_audits)
- [YouTube API Services Developer Policies](https://developers.google.com/youtube/terms/developer-policies)
- [Quota Calculator | YouTube Data API](https://developers.google.com/youtube/v3/determine_quota_cost)
- [YouTube API Services - Audit and Quota Extension Form](https://support.google.com/youtube/contact/yt_api_form?hl=en)
