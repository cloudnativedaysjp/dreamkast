require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cnds2024_intermission'
  task add_talks_for_cnds2024_intermission: :environment do
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

    conference = Conference.find_by(abbr: 'cnds2024')
    tracks = Hash[conference.tracks.map { |track| [track.name, track.id] }]

    track_a_talks = [
      %w[09:00:00 10:20:00 開始までしばらくお待ちください intermission],
      %w[10:20:00 10:30:00 オープニング intermission],
      #  10:30    10:50    Keynote 1
      #  10:50    11:10    Keynote 2
      #  11:10    11:30    Keynote 3
      #  11:30    11:50    Keynote 4
      #  11:50    12:10    Keynote 5
      %w[12:10:00 13:20:00 休憩 intermission],
      #  13:20    14:00    Session 1
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20    15:00    Session 2
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20    16:00    Session 3
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20    17:00    Session 4
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20    18:00    Session 5
      %w[18:10:00 18:20:00 クロージング intermission],
      %w[18:10:00 23:00:00 本日のイベントは終了しました intermission]
    ]

    other_track_talks = [
      %w[09:00:00 10:20:00 開始までしばらくお待ちください intermission],
      %w[10:20:00 10:30:00 トラックAでOP実施中！ intermission],
      %w[10:30:00 12:10:00 トラックAでキーノート配信中！ intermission],
      %w[12:10:00 13:20:00 休憩 intermission],
      #  13:20    14:00    Session 1
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20    15:00    Session 2
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20    16:00    Session 3
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20    17:00    Session 4
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20    18:00    Session 5
      %w[18:10:00 18:20:00 トラックAでクロージング実施中！ intermission],
      %w[18:10:00 23:00:00 本日のイベントは終了しました intermission]
    ]

    day = conference.conference_days.find_by(date: '2024-06-15')

    track_a_talks.each do |arr|
      param = { start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3] }
      add_talk(param.merge(type: 'Intermission', conference_id: conference.id, conference_day_id: day.id, track_id: tracks['A'], show_on_timetable: false))
    end

    %w[B C].each do |track_name|
      other_track_talks.each do |arr|
        param = { start_time: arr[0], end_time: arr[1], title: arr[2], abstract: arr[3] }
        add_talk(param.merge(type: 'Intermission', conference_id: conference.id, conference_day_id: day.id, track_id: tracks[track_name], show_on_timetable: false))
      end
    end
  end
end
