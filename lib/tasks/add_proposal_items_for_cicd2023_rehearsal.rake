require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_proposal_items_for_cicd2023_rehearsal'
  task add_proposal_items_for_cicd2023_rehearsal: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG
    conference = Conference.find_by(abbr: 'cicd2023')
    rehearsal_day = conference.conference_days.where(date: '2023-03-19').first

    proposal_items = {
      A: {
        Kubernetesリソースの安定稼働に向けた　TerratestによるHelmチャートのテスト自動化: [
          { label: 'assumed_visitor', params: ['83'] },
          { label: 'execution_phase', params: ['86', '87'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "大規模レガシーテストを倒すためのCI基盤の作り方": [
          { label: 'assumed_visitor', params: ['80', '81', '83'] },
          { label: 'execution_phase', params: ['86', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "トランクベース開発の実現に向けた開発プロセスとCIパイプラインの継続的改善": [
          { label: 'assumed_visitor', params: ['81', '82', '83'] },
          { label: 'execution_phase', params: ['86', '87'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "最高の開発者体験を目指してAWS CDKでCI/CDパイプラインを改善し続けている話": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '83'] },
          { label: 'execution_phase', params: ['86', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "ローコードで実現するDevOps ～継続的テスト編～": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '84'] },
          { label: 'execution_phase', params: ['86', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        UbieはなぜSnykを選んだのか？安全で高速なアプリケーション開発ライフサイクルの実現へ: [
          { label: 'assumed_visitor', params: ['80', '81', '82', '83', '84'] },
          { label: 'execution_phase', params: ['86', '87', '88'] },
          { label: 'whether_it_can_be_published', params: '92' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ]
      },
      B: {
        "自分のデータは自分で守る − あなたのCI/CDパイプラインをセキュアにする処方箋": [
          { label: 'assumed_visitor', params: ['80', '81', '82'] },
          { label: 'execution_phase', params: ['86', '87', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "GitHub Actionsと\"仲良くなる\"ための練習方法": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '83'] },
          { label: 'execution_phase', params: ['86', '87', '89'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "\"State of DevOps\" ウェブアプリケーションのdeliveryを考えるとき、今何をすればいいのか(実践編)": [
          { label: 'assumed_visitor', params: ['80', '81', '82'] },
          { label: 'execution_phase', params: ['86', '87', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "GitHub ActionsとDeployGateで始めるAndroidアプリのCI/CD": [
          { label: 'assumed_visitor', params: ['82'] },
          { label: 'execution_phase', params: ['86'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "昔とあるCI/CDツールを使って馬車馬のように働いていた私が、GitLabを使い始めて気付いた「CI/CDの質」": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '83', '84'] },
          { label: 'execution_phase', params: ['86'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '95' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "Karpenter を活用した GitLab CI/CD ジョブ実行基盤の自動スケール": [
          { label: 'assumed_visitor', params: ['80', '83'] },
          { label: 'execution_phase', params: ['86', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '95' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ]
      },
      C: {
        "インフラCI/CDの継続的改善の道のり": [
          { label: 'assumed_visitor', params: ['82', '83'] },
          { label: 'execution_phase', params: ['88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '95' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "小さく始める Blue/Green Deployment": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '83'] },
          { label: 'execution_phase', params: ['86', '87', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '95' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "インフラ専任者・チームがいない組織で開発ワークフローの継続的改善に挑戦してみた": [
          { label: 'assumed_visitor', params: ['81', '82', '83'] },
          { label: 'execution_phase', params: ['86', '87', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '95' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "OSSで構築するOpenAPI開発のCI/CD": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '83'] },
          { label: 'execution_phase', params: ['86', '87', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "すべてのアプリにWAFを組み込むCICDの実現 〜開発ツールとしてのNGINX WAF活用方法〜": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '85'] },
          { label: 'execution_phase', params: ['86', '87', '88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '95' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ],
        "OSSでセキュリティをCI/CDパイプラインに透過的に取込む方法": [
          { label: 'assumed_visitor', params: ['80', '81', '82', '83', '84'] },
          { label: 'execution_phase', params: ['88'] },
          { label: 'whether_it_can_be_published', params: '90' },
          { label: 'presentation_method', params: '94' },
          { label: 'session_time', params: '96' },
          { label: 'language', params: '97' }
        ]
      }
    }

    proposal_items.each do |track_name, items|
      track = conference.tracks.find_by(name: track_name.to_s)
      items.each do |title, params|
        talk = Talk.where(conference_id: conference.id, conference_day_id: rehearsal_day.id, track_id: track.id, title: title.to_s).first
        params.each do |param|
          proposal_item = ProposalItem.new(param.merge(conference_id: conference.id, talk_id: talk.id))
          proposal_item.save!
        end
      end
    end
  end
end
