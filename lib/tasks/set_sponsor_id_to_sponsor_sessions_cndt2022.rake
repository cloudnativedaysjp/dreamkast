namespace :db do
  desc 'set_sponsor_id_to_sponsor_sessions_cndt2022'
  task set_sponsor_id_to_sponsor_sessions_cndt2022: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG
    sponsors = Conference.includes(sponsors).find_by(abbr: 'cndt2022').sponsors

    sponsor_sessions = [
      # サーバレス開発〜関連する小さなサービス群を１プロジェクトにまとめた際のCIは？
      [1547, 'circleci'],
      # 仮
      [1529, 'dynatrace'],
      # GitLab流コラボレーションスタイル 〜DevOpsプラットフォームとSSOTで実現する「エンジニアのハッピーライフ」〜
      [1551, 'gitlab'],
      # Dynamic VM Scheduling in OpenStack
      [1516, 'gmo'],
      # 【対談】HashiCorp×TED -インフラのクラウドシフトを促進する最新機能とクラウドネイティブなマルチベンダー連携事例-
      [1597, 'hashicorp'],
      # PagerDutyで始めるAIOps − AIと自動化でインシデント対応をモダン化する
      [1544, 'pagerduty'],
      # 100%クラウドベースのデジタル体験基盤(DXP)開発フロー
      [1594, 'accuia'],
      # Google Kubernetes Engine (GKE) で実現する運用レスな世界
      [1543, 'google'],
      # 旅するCSO 鈴木いっぺいの「KubeCon現地リキャップ」
      [1555, 'creationline'],
      # NTTデータ流コスト効率術/iPaaS(MuleSoft)活用術（仮）
      [1598, 'nttdata'],
      # クラウドネイティブエンジニアの育成について実践していること
      [1540, 'casareal'],
      # CI/CDの次はCO-継続した最適化 !?  クラウドネイティブなSREのITリソース管理手法とは
      [1599, 'ibm'],
      # Kubernetes クラスタ管理からの開放 〜 アプリケーション開発を加速
      [1600, 'redhat'],
    ]

    ActiveRecord::Base.transaction do
      begin
        sponsor_sessions.each do |sponsor_session|
          talk_id = sponsor_session[0]
          sponsor_abbr = sponsor_session[1]

          talk = Talk.find(talk_id)
          sponsor = sponsors.find{|sponsor| sponsor.abbr == sponsor_abbr}

          if talk.sponsor.present?
            raise "Talk #{talk.id} (#{talk.title} is already sponsor session"
          end

          unless ENV['DRY_RUN'] == 'false'
            puts "[Dry Run] Set sponsor #{sponsor.name} to #{talk.title}"
          else
            talk.update!(sponsor_id: sponsor.id)
          end
        rescue => e
          puts(e)
        end
      end
    end
  end
end
