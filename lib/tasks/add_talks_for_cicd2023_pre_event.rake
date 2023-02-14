require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cicd2023_pre_event'
  task add_talks_for_cicd2023_pre_event: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG
    conference = Conference.find_by(abbr: 'cicd2023')
    pre_event_day = conference.conference_days.where(internal: true).first
    track_a = conference.tracks.find_by(name: 'A')

    track_a_talks = [
      {
        title: 'オープニング/見どころ紹介',
        start_time: '19:00:00',
        end_time: '19:15:00',
        abstract: 'intermission'
      },
      {
        title: 'GitHub self-hosted runner を利用した独自の CI プラットフォームの開発と運用',
        start_time: '19:15:00',
        end_time: '19:45:00',
        abstract: <<~EOS
          （Shun Tabata）

          近年はアプリのビルド時間の増大により CI サービスにかかるコストが増えています。一方で Jenkins 等の OSS を使用して時間当たりのコストを下げようとするとビルドマシンの管理コストが発生してしまいます。これらの問題に対応するため、独自の社内 CI プラットフォームを開発いたしました。開発にあたっては GitHub Actions の self-hosted runner を利用し、それを動的に実行する仕組みを作ることで、フレキシブルな CI プラットフォームを迅速に開発することができました。本セッションでは開発したプラットフォームの紹介と、運用をしていく上で発生した諸問題について解説します。
        EOS
      },
      {
        title: '休憩',
        start_time: '19:45:00',
        end_time: '19:50:00',
        abstract: 'intermission'
      },
      {
        title: 'Terraform管理下のマネージドリソースとk8sリソースを一元的にGitOpsするまでの試行錯誤',
        start_time: '19:50:00',
        end_time: '20:20:00',
        abstract: <<~EOS
          （Yuya Mizorogi）

          Weave GitOps Terraform Controller を用いて Terraform の実行を Kubernetes リソースとして管理することにより、パブリッククラウド上のマネージドリソースと Kubernetes 上のリソースの GitOps を一元化した取り組みについてお話しします。 Flux に昨年サポートされた OCI Artifacts およびマネージドコンテナレジストリへのアクセスのための認証方針など上記実現に向けて必要となる技術についても触れます。
        EOS
      },
      {
        title: '休憩',
        start_time: '20:20:00',
        end_time: '20:30:00',
        abstract: 'intermission'
      },
      {
        title: 'オンプレミスk8s基盤をまるごとVMで仮想化した検証環境とその活用',
        start_time: '20:30:00',
        end_time: '21:00:00',
        abstract: <<~EOS
          (Soju Yamashita)

           サイボウズでは，自社データセンター上のインフラ構築の仕組みを開発しており、サーバーのプロビジョニング、Kubernetesクラスタの構築を自動化しています。 このKubernetes基盤の構成を検証するため，VMを用いてデータセンタを丸ごと仮想化した環境(dctest環境)を利用しています。 この環境をCIや開発で利用するためにカスタムコントローラを開発しました。 本発表では，この仮想データセンタの概要とその活用について紹介します。
        EOS
      },
      {
        title: 'クロージング/CICD2023見どころ紹介',
        start_time: '21:00:00',
        end_time: '21:10:00',
        abstract: 'intermission'
      },
      {
        title: '懇親・解散',
        start_time: '21:10:00',
        end_time: '22:00:00',
        abstract: 'intermission'
      }
    ]

    track_a_talks.each do |param|
      talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: pre_event_day.id, track_id: track_a.id, show_on_timetable: true))
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
