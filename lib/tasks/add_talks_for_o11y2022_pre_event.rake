require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_o11y2022_pre_event'
  task add_talks_for_o11y2022_pre_event: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'o11y2022')
    pre_event_day = conference.conference_days.where(internal: true).first
    track_a = conference.tracks.find_by(name: 'A')
    track_b = conference.tracks.find_by(name: 'B')

    track_a_talks = [
      {
        title: 'Opening',
        start_time: '19:00:00',
        end_time: '19:05:00',
        abstract: 'intermission'
      },
      {
        title: 'What it means to be "observable" in Ubie',
        start_time: '19:05:00',
        end_time: '19:45:00',
        abstract: ''
      },
      {
        title: '休憩',
        start_time: '19:45:00',
        end_time: '19:50:00',
        abstract: 'intermission'
      },
      {
        title: 'Grafana Lokiで構築する1日20TBの大規模ログモニタリング基盤',
        start_time: '19:50:00',
        end_time: '20:30:00',
        abstract: ''
      },
      {
        title: '休憩',
        start_time: '20:30:00',
        end_time: '20:35:00',
        abstract: 'intermission'
      },
      {
        title: 'Co-ChairによるObservability Conference 2022みどころ',
        start_time: '20:35:00',
        end_time: '20:55:00',
        abstract: ''
      },
      {
        title: 'Closing',
        start_time: '20:55:00',
        end_time: '21:00:00',
        abstract: 'intermission'
      }
    ]

    track_b_talks = [
      {
        title: 'Opening',
        start_time: '19:00:00',
        end_time: '19:05:00',
        abstract: 'intermission'
      },
      {
        title: '分散トレーシングの歴史、計装、そしてその活用プラクティス',
        start_time: '19:05:00',
        end_time: '19:45:00',
        abstract: ''
      },
      {
        title: '休憩',
        start_time: '19:45:00',
        end_time: '19:50:00',
        abstract: 'intermission'
      },
      {
        title: 'Observe the Conference',
        start_time: '19:50:00',
        end_time: '20:30:00',
        abstract: ''
      },
      {
        title: '休憩',
        start_time: '20:30:00',
        end_time: '20:35:00',
        abstract: 'intermission'
      },
      {
        title: 'Closing',
        start_time: '20:55:00',
        end_time: '21:00:00',
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
    end

    track_b_talks.each do |param|
      talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: pre_event_day.id, track_id: track_b.id, show_on_timetable: false))
      talk.save!
      if talk.abstract != 'intermission'
        proposal = Proposal.new(conference_id: conference.id, talk_id: talk.id, status: 1)
        proposal.save!
      end
    end
  end
end
