require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cndt2022_pre_event'
  task add_talks_for_cndt2022_pre_event: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'cndt2022')
    pre_event_day = conference.conference_days.where(internal: true).first
    track_a = conference.tracks.find_by(name: 'A')
    track_b = conference.tracks.find_by(name: 'B')

    track_a_talks = [
      {
        title: 'オープニング',
        start_time: '19:00:00',
        end_time: '19:05:00',
        abstract: 'intermission'
      },
      {
        title: 'CNDT2022のみどころ紹介',
        start_time: '19:05:00',
        end_time: '19:20:00',
        abstract: 'intermission'
      },
      {
        title: 'Feature 環境の自動生成と B/G Deployment で効率的かつ安全なリリースプロセスを構築',
        start_time: '19:20:00',
        end_time: '20:00:00',
        abstract: <<~EOS
          （Sakuya Inokuma）

          ダウンタイムを極小化し、安全にリリースするために、B/G Deployment の導入を検討・実践されている方は多くいらっしゃると思います。 Red Frasco では、複数コンテナの整合性を担保しつつ B/G Deployment を実行するパイプラインを構築しました。 加えて、Feature ブランチごとにテスト環境を自動構築するパイプラインも構築し、複数人での開発・リリースを効率的に行っています。 本セッションでは、実際に構築したパイプラインや構築時、運用時の苦労を事例として紹介します。
        EOS
      },
      {
        title: '休憩',
        start_time: '20:00:00',
        end_time: '20:10:00',
        abstract: 'intermission'
      },
      {
        title: 'クラウドのスケールメリットと地理的特性をデータベースにも活かしましょう',
        start_time: '20:10:00',
        end_time: '20:40:00',
        abstract: <<~EOS
          （Tomohiro Ichimura）

          クラウドのスケールメリットと地理的特性をデータベースにも活かしましょう "データベースのスケールには課題が多く、今日のマネージドサービスでは個別最適や互換性がトレードオフとなります。読めないワークロード、増減するデータサイズ、複数拠点/複数クラウド、データの一貫性と地理的なレイテンシーも考慮が必要です。 オープンソースの分散SQLデータベースYugabyteDBが、このようなマルチクウラドやKubernetesにおけるデータ処理の課題をどう解決するのかご紹介いたします。
        EOS
      },
      {
        title: 'コミュニティ紹介: Cloud Native Developers JP',
        start_time: '20:40:00',
        end_time: '20:50:00',
        abstract: <<~EOS
          (hhiroshell）

          Cloud Native Developers JPは、”Cloud Nativeなテクノロジースタック” を勉強するコミュニティです。Kubernetes、CI/CD、Service Mesh ...etc 各回技術トピック単位のテーマを設け、その道の有識者を招いて勉強会を開催しています。
        EOS
      },
      {
        title: 'コミュニティ紹介:Kubernetes Meetup Novice',
        start_time: '20:50:00',
        end_time: '21:00:00',
        abstract: <<~EOS
          （taxin）

          「Kubernetes Meetup Novice」は、これからKubernetesを使ってみよう、もしくはKubernetesを使い始めた方を対象に、Kubernetesに対する理解を深めていただくのはもちろん、「わからない (できない) 状態」を許容し、皆様が「より楽しく学び、ステップアップしていく」をお手伝させていただくことをコンセプトとしたコミュニティです。
        EOS
      },
      {
        title: 'コミュニティ紹介:Kubernetes Meetup Tokyo / K8s@home / Kubernetes 変更内容共有会 / オンプレML基盤 on Kubernetes 〜PFN、ヤフー〜 / Prometheus Meetup Tokyo',
        start_time: '21:00:00',
        end_time: '21:10:00',
        abstract: <<~EOS
          （Suda Kazuki）

          「Kubernetes Meetup Tokyo」は強力なコンテナオーケストレーションツールである Kubernetes について詳しく聞く会です！2016年5月に一回目を開催して次回で54回目になります。コロナ禍でも変わらず1, 2ヶ月に一度開催しており、登壇者、LT を常に募集していますので、ぜひ気軽に応募ください。

          「K8s@home」は、自宅でラズパイや NUC、VM、そのほか VPS 等を使って個人の趣味として Kubernetes クラスタを構築、運用する人たちが情報交換、懇親する場所です。2022年10月に一回目を開催した新しいミートアップで、とても盛り上がりました。今後もやっていきますので、自宅/趣味クラスタをやってる/やりたい方あつまれ〜

          「Kubernetes 変更内容共有会」は、Kubernetes マイナーバージョンリリースに合わせて開催し、各 SIG の担当者がそのマイナーバージョンリリースでの重要/おもしろポイントを紹介する勉強会です。Kubernetes の“細かい“変更内容に興味ある方は、ぜひご参加ください。

          「オンプレML基盤 on Kubernetes 〜PFN、ヤフー〜」は、ヤフー株式会社と株式会社 Preferred Networks というオンプレの Kubernetes クラスタで機械学習基盤を構築している2社のエンジニアが最近の取り組みを共有する勉強会です。半年に一度開催しています。オンプレ、Kubernetes、MLOps 等のワードに興味ある方はぜひご参加ください。

          「Prometheus Meetup Tokyo」は、メトリクスモニタリングツールである Prometheus について詳しく聞く会です！久しく開催できておりませんが、もし一緒にやりたい、発表したい方がいればぜひご連絡ください。
        EOS
      },
      {
        title: 'クロージング',
        start_time: '21:10:00',
        end_time: '21:15:00',
        abstract: 'intermission'
      }
    ]

    track_b_talks = [
      {
        title: 'オープニング',
        start_time: '19:00:00',
        end_time: '19:05:00',
        abstract: 'intermission'
      },
      {
        title: 'CNDT2022のみどころ紹介',
        start_time: '19:05:00',
        end_time: '19:20:00',
        abstract: 'intermission'
      },
      {
        title: 'ソフトウェアエンジニアにとってサステナブルなIaCを実現するための取り組み',
        start_time: '19:20:00',
        end_time: '20:00:00',
        abstract: <<~EOS
          （Kazuki Aizawa）

          Infrastructure as Codeによる構成管理は、品質の向上とリリースの高速化のために非常に有用ですが、ソフトウェアの成長とともにパラメータ管理が複雑化し、コードの見通しが悪くなるといった問題が発生します。 NTTコミュニケーションズでは、この問題を解決しつつ、ソフトウェアのインフラストラクチャ構成とそれをデプロイするワークフローを統一的なインターフェースで定義できる独自のIaC実装をCUE言語を利用して開発しました。 本セッションでは、この独自のIaC実装であるCloud Native Adapterについて、実例を交えながらご紹介します。
        EOS
      },
      {
        title: '休憩',
        start_time: '20:00:00',
        end_time: '20:10:00',
        abstract: 'intermission'
      },
      {
        title: 'CNDT 2021 Keynote Replay クラウドネイティブが強み！イマドキの銀行システムの姿',
        start_time: '20:10:00',
        end_time: '20:40:00',
        abstract: <<~EOS
          （Masaaki Miyamoto）

           2021年5月に開業したみんなの銀行。我々が目指す先は、宇宙一お客様のことを考える銀行であり、そもそも今の時代において、『銀行って何？』から再定義することを目的として設立しました。システムも従来の重厚長大なシステムに捕らわれず、「今の時代」に最適な組み合わせを選択した結果、フルクラウド銀行システムが誕生しました。その姿と今後の組織の展望をお話しします。

           本セッションは、CloudNative Days 2021 Keynoteでご登壇頂いた内容の再演です。
        EOS
      },
      {
        title: 'コミュニティ紹介:Container Runtime Meetup',
        start_time: '20:40:00',
        end_time: '20:50:00',
        abstract: <<~EOS
          （徳永 航平）

           Container Runtime Meetupは、コンテナ技術、特にランタイムに注目しながら要素技術や最新動向など情報交換をするミートアップです。ランタイムはKubernetesなどの上位ツールやユーザから指示を受けてマシン上でコンテナを作成管理する、縁の下の力持ち的なソフトウェアです。これまでに、Dockerやruncのような広く使われる技術からFirecrackerやgVisorのような新しいものまで、幅広い話題を共有してきました。
        EOS
      },
      {
        title: 'コミュニティ紹介:Forkwell Community',
        start_time: '20:50:00',
        end_time: '21:00:00',
        abstract: <<~EOS
          （河又 涼）

          Forkwell Communityは居並ぶコミュニティと違い、Cloud Nativeに必ずしも特化したコミュニティではございません。しかし、2020年4月に2,000名を超える登録となったInfra Studyの第一回に始まり、Cloud Native LoungeやSRE Gapsなど数々のインフラ領域のイベントを行なってきましたのでそれらの活動と併せて普段の活動をご紹介します。
        EOS
      },
      {
        title: 'CNDT2022実行委員会活動紹介: Broadcast チームのオブザーバビリティ向上活動',
        start_time: '21:00:00',
        end_time: '21:10:00',
        abstract: <<~EOS
          （Koji Kawamura）

          Cloud Native Days では OBS を使ってストリーム配信を行なっています。本セッションでは、配信システムの開発、運用を担う Broadcast チームの活動の一環として、Elasticsearch、Kibana を利用した OBS のオブザーバビリティ向上への取り組みを紹介します。
        EOS
      },
      {
        title: 'クロージング',
        start_time: '21:10:00',
        end_time: '21:15:00',
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

    track_b_talks.each do |param|
      talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: pre_event_day.id, track_id: track_b.id, show_on_timetable: true))
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
