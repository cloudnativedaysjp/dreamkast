require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cndt2023_pre_intermission'
  task add_talks_for_cndt2023_pre_intermission: :environment do
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

    conference = Conference.find_by(abbr: 'cndt2023')
    tracks = Hash[conference.tracks.map { |track| [track.name, track.id] }]

    track_talks = [
      %w[18:30:00 19:00:00 開始までしばらくお待ちください intermission],
      %w[19:00:00 19:10:00 オープニング intermission],
      %w[19:10:00 19:15:00 移動時間 intermission],
      %w[19:15:00 19:55:00 セッション1 intermission],
      %w[19:55:00 20:00:00 移動時間 intermission],
      %w[20:00:00 20:40:00 セッション2 intermission],
      %w[20:45:00 20:55:00 CNDT2023の見どころ紹介 intermission],
      %w[20:55:00 21:00:00 クロージング intermission],
      %w[21:00:00 21:10:00 本日のイベントは終了しました intermission]
    ]

    day = conference.conference_days.find_by(date: '2023-11-20')

    %w[A B].each do |track_name|
      track_talks.each do |arr|
        param = { start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3] }
        add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id: tracks[track_name], show_on_timetable: false))
      end
    end
  end
end
