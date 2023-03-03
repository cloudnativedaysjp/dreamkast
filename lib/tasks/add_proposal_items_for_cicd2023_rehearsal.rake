require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_proposal_items_for_cicd2023_rehearsal'
  task add_proposal_items_for_cicd2023_rehearsal: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG
    conference = Conference.find_by(abbr: 'cicd2023')
    rehearsal_day = conference.conference_days.where(date: '2023-03-04').first
    track_a = conference.tracks.find_by(name: 'A')


    proposal_items = {
      "大規模レガシーテストを倒すためのCI基盤の作り方": [
        { label: 'assumed_visitor', params: ['80', '81', '83'] },
        { label: 'execution_phase', params: ['86', '88'] },
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
      UbieはなぜSnykを選んだのか？安全で高速なアプリケーション開発ライフサイクルの実現へ: [
        { label: 'assumed_visitor', params: ['80', '81', '82', '83', '84'] },
        { label: 'execution_phase', params: ['86', '87', '88'] },
        { label: 'whether_it_can_be_published', params: '92' },
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
      "ローコードで実現するDevOps ～継続的テスト編～": [
        { label: 'assumed_visitor', params: ['80', '81', '82', '84'] },
        { label: 'execution_phase', params: ['86', '88'] },
        { label: 'whether_it_can_be_published', params: '90' },
        { label: 'presentation_method', params: '94' },
        { label: 'session_time', params: '96' },
        { label: 'language', params: '97' }
      ],
      Kubernetesリソースの安定稼働に向けた　TerratestによるHelmチャートのテスト自動化: [
        { label: 'assumed_visitor', params: ['83'] },
        { label: 'execution_phase', params: ['86', '87'] },
        { label: 'whether_it_can_be_published', params: '90' },
        { label: 'presentation_method', params: '94' },
        { label: 'session_time', params: '96' },
        { label: 'language', params: '97' }
      ]
    }

    proposal_items.each do |key, items|
      items.each do |item|
        talk = Talk.where(conference_id: conference.id, conference_day_id: rehearsal_day.id, track_id: track_a.id, title: key).first
        proposal_item = ProposalItem.new(item.merge(conference_id: conference.id, talk_id: talk.id))
        proposal_item.save!
      end
    end
  end
end
