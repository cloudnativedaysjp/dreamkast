require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cnds2025_intermission'
  task add_talks_for_cnds2025_intermission: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    def add_talk(param)
      talk = Talk.new(param)
      talk.save!
      if talk.abstract != 'intermission'
        proposal = Proposal.new(conference_id: conference.id, talk_id: talk.id, status: 1)
        proposal.save!
      end
      video = Video.new(talk_id: talk.id, on_air: false)
      video.save!
    end

    conference = Conference.find_by(abbr: 'cnds2025')
    tracks = Hash[conference.tracks.map { |track| [track.name, track.id] }]

    track_a_talks = [
      %w[08:00:00 10:20:00 開始までしばらくお待ちください intermission],
      %w[10:20:00 10:30:00 オープニング intermission],
      %w[12:20:00 13:20:00 休憩 intermission],
      %w[14:00:00 14:20:00 休憩 intermission],
      %w[15:00:00 15:20:00 休憩 intermission],
      %w[16:00:00 16:20:00 休憩 intermission],
      %w[17:00:00 17:20:00 休憩 intermission],
      %w[18:00:00 18:10:00 休憩 intermission],
      %w[18:10:00 19:00:00 クロージング intermission],
      %w[19:00:00 20:00:00 本日のイベントは終了しました intermission]
    ]

    other_track_talks = [
      %w[08:00:00 10:20:00 開始までしばらくお待ちください intermission],
      %w[10:20:00 10:30:00 トラックAでオープニング実施中！ intermission],
      %w[10:30:00 12:20:00 トラックAでキーノート配信中！ intermission],
      %w[12:20:00 13:20:00 休憩 intermission],
      %w[14:00:00 14:20:00 休憩 intermission],
      %w[15:00:00 15:20:00 休憩 intermission],
      %w[16:00:00 16:20:00 休憩 intermission],
      %w[17:00:00 17:20:00 休憩 intermission],
      %w[18:00:00 18:10:00 休憩 intermission],
      %w[18:10:00 19:00:00 トラックAでクロージング実施中！ intermission],
      %w[19:00:00 20:00:00 本日のイベントは終了しました intermission]
    ]

    days = conference.conference_days.where(internal: false)

    days.each do |day|
      track_a_talks.each do |arr|
        param = { start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3] }
        add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id: tracks['A'], show_on_timetable: false))
      end

      tracks.except('A').each do |_track_name, track_id|
        other_track_talks.each do |arr|
          param = { start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3] }
          add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id:, show_on_timetable: false))
        end
      end

      # https://cloudnativedays.slack.com/archives/C087QPW51RQ/p1745897807167199?thread_ts=1745857454.682939&cid=C087QPW51RQ
      # 各トラックにComing Soonのセッションを追加
      tracks.each do |_track_name, track_id|
        param = { start_time: '16:20:00', end_time: '17:00:00', title: 'Coming Soon', abstract: '魅力的なセッションを企画中！' }
        add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id:, show_on_timetable: true))
      end
    end
  end
end
