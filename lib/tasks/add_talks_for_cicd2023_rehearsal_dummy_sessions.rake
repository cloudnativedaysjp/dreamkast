require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cicd2023_rehearsal_dummy_sessions'
  task add_talks_for_cicd2023_rehearsal_dummy_sessions: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG
    conference = Conference.find_by(abbr: 'cicd2023')
    rehearsal_day = conference.conference_days.where(date: '2023-03-04').first
    track_a = conference.tracks.find_by(name: 'A')

    track_a_talks = [
      {
        title: '大規模レガシーテストを倒すためのCI基盤の作り方',
        start_time: '12:20:00',
        end_time: '13:00:00',
        abstract: <<~EOS
          筆者の所属企業では現在CI基盤の作り直しを行なっています。従来のCI基盤には以下のような課題がありました。

          * レガシーなテストがあり、環境に触れづらく、なるべくその まま移行したい
          * テスト件数が非常に多い（10,000件〜）
          * 富豪的にSaaS/クラウドリソースを使っており、コストが最適でない
          * コードリポジトリであるGitHubとの連携をもっといい感じにしたい

          これらの課題を解決するためにどのような技術選定とアーキテクチャ設計をし、またいかにコスト等を最適化したかをお話しします。
          また、CI基盤のベ ースとしてCloud Build、Cloud Functions、Cloud Pub/SubなどGoogle Cloudのサービスを用いており、それらについての具体的なTipsも交える予定です。"
        EOS
      },
      {
        title: '最高の開発者体験を目指してAWS CDKでCI/CDパイプラインを改善し続けている話',
        start_time: '13:20:00',
        end_time: '14:00:00',
        abstract: <<~EOS
          私達NewsPicks/AlphaDriveは、プロダクト開発者全員が「ユーザーに価値を届ける」ことを重視し、フロントエンド・バックエンドの開発に限らずインフラ・DevOpsにも積極的に関与し ています。
          AWS CDKの導入により、開発者自身が馴染みのあるプログラミング言語でインフラやCI/CDパイプラインの構築・管理を行うことができ、開発者がフルサイクルのオーナーシッ プを発揮することに役立っています。しかし、サービスの規模やチームが拡大するにつれて、運用上の問題も見えてきました。
          本セッションでは、CDKを導入したことによる恩恵や私達のCI/CDパイプライン、また抱えている問題やそれに対する試行錯誤をご紹介させていただきます。
          (NewsPicks/AlphaDriveで20分ずつの2パート40分の発表を予定しています)
        EOS
      },
      {
        title: 'UbieはなぜSnykを選んだのか？安全で高速なアプリケーション開発ライフサイクルの実現へ',
        start_time: '14:20:00',
        end_time: '15:00:00',
        abstract: <<~EOS
          ヘルスケア領域において「テクノロジーで人々を適切な医療に案内する」ことをミッションに掲げるUbieは、開発ライフサイクル全体に亘りセキュリティを担保しながらも高速にアプリ ケーション開発ができるSnykを導入しました。本セッションでは、高速なアプリケーション開発ライフサイクルを回すために必要な開発者セキュリティについて、またUbieがなぜSnykを選択 したのかについてお話しします。'
        EOS
      },
      {
        title: 'トランクベース開発の実現に向けた開発プロセスとCIパイプラインの継続的改善',
        start_time: '15:20:00',
        end_time: '16:00:00',
        abstract: <<~EOS
          トランクベース開発とは、Gitのようなバージョニングを用いた組織開発において、高いデリバリー速度と開発パフォーマンスを維持するために考案された手法です。
          我々認証認可チームはこの手法を用いた組織開発を2年以上行っており、また並行して開発パフォーマンスの可視化、ボトルネックの洗い出し、そして開発プロセスやCIパイプラインの見直しを通して、開発速度の継続的な改善に努めてきました。本セッションでは、この2年間を通して得られた知見をもとに、トランクベース開発の具体的な実践方法について解説します。
        EOS
      },
      {
        title: 'ローコードで実現するDevOps ～継続的テスト編～',
        start_time: '16:20:00',
        end_time: '17:00:00',
        abstract: <<~EOS
          効果的なテストの自動化は、DevOpsを実現するための重要な手段の1つです。DevOpsの文脈で、様々な自動化がイノベーションを起こすには不可欠であることは周知の事実ですが、皆さまは現状の結果に満足しているでしょうか。
          このセッションでは、mablが提供するローコードプラットフォームによって、パイプライン上に自動テストを直接統合する方法をご紹介し ます。チーム全体がテスト工程を早期に実施(シフトレフト)できるだけでなく、これまで抱えていたパイプライン全体におけるテスト工程の課題を克服する戦略もご紹介します。
        EOS
      },
      {
        title: 'Kubernetesリソースの安定稼働に向けた　TerratestによるHelmチャートのテスト自動化',
        start_time: '17:20:00',
        end_time: '18:00:00',
        abstract: <<~EOS
          ソフトバンクでは、Fluxcdを用いてGitOpsによる開発を進めています。
          GitOpsを実現したことにより、Gitリポジトリのコードの更新だけでデプロイできるため、環境の管理が楽になりました。
          しかし管理するコードが増えるにつれて、デプロイ後のバグが頻出するようになり、品質が低下し管理コストが大幅に増大してしまいました。
          そこで私たちは、品質向上 と生産性向上を目的として、一般的なアプリケーションのように、インフラに対する単体テスト・結合テストを実装しました。
          今回の発表では、Terratestを用いたインフラの単体テスト・結合テストの考え方と実装についてお話します。
        EOS
      }
    ]

    track_a_talks.each do |param|
      talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: rehearsal_day.id, track_id: track_a.id, show_on_timetable: true))
      talk.save!
      if talk.abstract != 'intermission'
        proposal = Proposal.new(conference_id: conference.id, talk_id: talk.id, status: 1)
        proposal.save!
      end
      video = Video.new(talk_id: talk.id, on_air: false)
      video.save!
    end
  end
end
