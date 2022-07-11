require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cnsec2022_pre_event'
  task add_talks_for_cnsec2022_pre_event: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'cnsec2022')
    pre_event_day = conference.conference_days.where(internal: true).first
    track_a = conference.tracks.find_by(name: 'A')
    track_b = conference.tracks.find_by(name: 'B')

    track_a_talks = [
      {
        title: 'Co-ChairによるCNSec概要、見所紹介',
        start_time: '19:00:00',
        end_time: '19:20:00',
        abstract: 'intermission'
      },
      {
        title: '過去CNDでのSecurityセッション紹介',
        start_time: '19:20:00',
        end_time: '19:40:00',
        abstract: 'intermission'
      },
      {
        title: 'サイバー攻撃から Kubernetes クラスタを守るための効果的なセキュリティ対策',
        start_time: '19:40:00',
        end_time: '20:00:00',
        abstract: ''
      },
      {
        title: '休憩',
        start_time: '20:00:00',
        end_time: '20:10:00',
        abstract: 'intermission'
      },
      {
        title: 'OSSライブラリは便利、でも危険？いやいや、SBoMで守ろう！',
        start_time: '20:10:00',
        end_time: '20:50:00',
        abstract: ''
      },
      {
        title: 'Closing',
        start_time: '20:50:00',
        end_time: '20:55:00',
        abstract: 'intermission'
      }
    ]

    track_b_talks = [
      {
        title: 'TrackBでイベント開催中',
        start_time: '19:00:00',
        end_time: '19:40:00',
        abstract: 'intermission'
      },
      {
        title: '【CND Replay】How We Harden Platform Security at Mercari',
        start_time: '19:40:00',
        end_time: '20:00:00',
        abstract: ''
      },
      {
        title: '休憩',
        start_time: '20:00:00',
        end_time: '20:10:00',
        abstract: 'intermission'
      },
      {
        title: '脅威へ、しなやかかつ持続可能に対応するためのIaC環境 〜循環型IaC〜',
        start_time: '20:10:00',
        end_time: '20:50:00',
        abstract: ''
      },
      {
        title: 'このトラックの配信は終了しました',
        start_time: '20:50:00',
        end_time: '20:55:00',
        abstract: 'intermission'
      }
    ]

    track_a_talks.each do |param|
      talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: pre_event_day.id, track_id: track_a.id, show_on_timetable: false))
      talk.save!
      if talk.abstract != 'intermission'
        proposal = Proposal.new(conference_id: conference.id, talk_id: talk.id, status: 1)
        proposal.save!
      end
      video = Video.new(talk_id: talk.id, on_air: false)
      video.save!
    end

    track_b_talks.each do |param|
      talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: pre_event_day.id, track_id: track_b.id, show_on_timetable: false))
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
