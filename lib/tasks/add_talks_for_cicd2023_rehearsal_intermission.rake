require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cicd2023_rehearsal_intermission'
  task add_talks_for_cicd2023_rehearsal_intermission: :environment do
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

    conference = Conference.find_by(abbr: 'cicd2023')
    tracks = Hash[conference.tracks.map { |track| [track.name, track.id] }]

    track_a_talks = [
      %w[11:00:00 12:00:00 開始までしばらくお待ちください intermission],
      %w[12:00:00 12:20:00 オープニング intermission],
      #  12:20:00 13:00:00 Session
      %w[13:00:00 13:20:00 休憩 intermission],
      #  13:20:00 14:00:00 Session
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20:00 15:00:00 Session
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20:00 16:00:00 Session
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20:00 17:00:00 Session
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20:00 18:00:00 Session
      %w[18:00:00 18:20:00 『よるイベ！』は18:20から開催します。しばらくお待ちください intermission],
      %w[18:20:00 20:00:00 よるイベ！ intermission],
      %w[20:00:00 23:00:00 本日のイベントは終了しました intermission]
    ]

    other_track_talks = [
      %w[11:00:00 12:00:00 開始までしばらくお待ちください intermission],
      %w[12:00:00 12:20:00 オープニング intermission],
      #  12:20:00 13:00:00 Session
      %w[13:00:00 13:20:00 休憩 intermission],
      #  13:20:00 14:00:00 Session
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20:00 15:00:00 Session
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20:00 16:00:00 Session
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20:00 17:00:00 Session
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20:00 18:00:00 Session
      %w[18:00:00 18:20:00 『よるイベ！』は18:20から開催します。しばらくお待ちください intermission],
      %w[18:20:00 20:00:00 トラックAにて『よるイベ！』を配信中！ intermission],
      %w[20:00:00 23:00:00 本日のイベントは終了しました intermission]
    ]


    day = conference.conference_days.find_by(date: '2023-03-19')

    track_a_talks.each do |arr|
      param = { start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3] }
      add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id: tracks['A'], show_on_timetable: true))
    end

    %w[B C].each do |track_name|
      other_track_talks.each do |arr|
        param = { start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3] }
        add_talk(param.merge(conference_id: conference.id, conference_day_id: day.id, track_id: tracks[track_name], show_on_timetable: true))
      end
    end
  end
end
