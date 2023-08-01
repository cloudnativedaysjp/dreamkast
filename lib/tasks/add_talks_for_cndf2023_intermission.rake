require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cndf2023_intermission'
  task add_talks_for_cndf2023_intermission: :environment do
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

    conference = Conference.find_by(abbr: 'cndf2023')
    tracks = Hash[conference.tracks.map { |track| [track.name, track.id] }]

    track_a_talks = [
      %w[10:00:00 10:50:00 開始までしばらくお待ちください intermission],
      %w[10:50:00 11:00:00 オープニング intermission],
      #  11:00:00 11:20:00 Keynote 1
      %w[11:20:00 11:25:00 休憩 intermission],
      #  11:25:00 11:45:00 Keynote 2
      %w[11:45:00 11:50:00 休憩 intermission],
      #  11:50:00 12:10:00 Keynote 3
      %w[12:10:00 12:15:00 休憩 intermission],
      #  12:15:00 12:35:00 Keynote 4
      %w[12:35:00 12:40:00 休憩 intermission],
      #  12:40:00 13:00:00 Keynote 5
      %w[13:00:00 14:00:00 休憩 intermission],
      #  14:00:00 14:40:00 Session 1
      %w[14:40:00 15:00:00 休憩 intermission],
      #  15:00:00 15:40:00 Session 2
      %w[15:40:00 16:00:00 休憩 intermission],
      #  16:00:00 16:40:00 Session 3
      %w[16:40:00 17:00:00 休憩 intermission],
      #  17:00:00 17:40:00 Session 4
      %w[17:40:00 18:00:00 休憩 intermission],
      #  18:00:00 18:40:00 Session 5
      %w[18:40:00 18:50:00 休憩 intermission],
      %w[18:50:00 19:00:00 クロージング intermission],
      %w[19:00:00 20:00:00 よるイベ intermission],
      %w[20:00:00 23:00:00 本日のイベントは終了しました intermission]
    ]

    other_track_talks = [
      %w[10:00:00 10:50:00 開始までしばらくお待ちください intermission],
      %w[10:50:00 11:00:00 トラックAでOP実施中！ intermission],
      %w[11:00:00 13:00:00 トラックAでキーノート配信中！ intermission],
      %w[13:00:00 14:00:00 休憩 intermission],
      #  14:00:00 14:40:00 Session 1
      %w[14:40:00 15:00:00 休憩 intermission],
      #  15:00:00 15:40:00 Session 2
      %w[15:40:00 16:00:00 休憩 intermission],
      #  16:00:00 16:40:00 Session 3
      %w[16:40:00 17:00:00 休憩 intermission],
      #  17:00:00 17:40:00 Session 4
      %w[17:40:00 18:00:00 休憩 intermission],
      #  18:00:00 18:40:00 Session 5
      %w[18:40:00 18:50:00 休憩 intermission],
      %w[18:50:00 19:00:00 トラックAでクロージング実施中！ intermission],
      %w[19:00:00 20:00:00 トラックAでよるイベ実施中！ intermission],
      %w[19:00:00 23:00:00 本日のイベントは終了しました intermission]
    ]

    day = conference.conference_days.find_by(date: '2023-08-03')

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
