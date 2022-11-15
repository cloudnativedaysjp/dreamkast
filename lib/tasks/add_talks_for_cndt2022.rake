require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cndt2022'
  task add_talks_for_cndt2022: :environment do
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

    conference = Conference.find_by(abbr: 'cndt2022')
    conference_days = conference.conference_days.where(internal: false)
    tracks = Hash[conference.tracks.map{|track| [track.name, track.id]}]

    track_a_talks = [
      %w[09:00:00 09:45:00 開始までしばらくお待ちください intermission],
      %w[09:45:00 10:00:00 オープニング intermission],
      #  10:00:00 12:15:00 Keynotes
      %w[12:15:00 13:20:00 休憩 intermission],
      #  13:20:00 14:00:00 Session
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20:00 15:00:00 Session
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20:00 16:00:00 Session
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20:00 17:00:00 Session
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20:00 18:00:00 Session
      %w[18:00:00 18:15:00 クロージング intermission],
      %w[18:15:00 20:00:00 夜イベント(仮) intermission],
      %w[20:00:00 23:00:00 本日のイベントは終了しました intermission]
    ]

    other_track_talks = [
      %w[09:00:00 09:45:00 開始までしばらくお待ちください intermission],
      %w[09:45:00 10:00:00 トラックAにてオープニングを配信中！ intermission],
      %w[10:00:00 12:15:00 トラックAにてキーノートを配信中！ intermission],
      %w[12:15:00 13:20:00 休憩 intermission],
      #  13:20:00 14:00:00 Session
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20:00 15:00:00 Session
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20:00 16:00:00 Session
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20:00 17:00:00 Session
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20:00 18:00:00 Session
      %w[18:00:00 18:15:00 トラックAにてクロージングを配信中！ intermission],
      %w[18:15:00 20:00:00 トラックAにて夜イベント(仮)を配信中！ intermission],
      %w[20:00:00 23:00:00 本日のイベントは終了しました intermission]
    ]

    conference_days.each do |day|
      track_a_talks.each do |arr|
        param = {start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3]}
        add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id: tracks['A'], show_on_timetable: true))
      end

      %w[B C D E F].each do |track_name|
        other_track_talks.each do |arr|
          param = {start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3]}
          add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id: tracks[track_name], show_on_timetable: true))
        end
      end
    end
  end
end
