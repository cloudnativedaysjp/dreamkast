require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cndw2024_intermission'
  task add_talks_for_cndw2024_intermission: :environment do
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

    conference = Conference.find_by(abbr: 'cndw2024')
    tracks = Hash[conference.tracks.map { |track| [track.name, track.id] }]

    track_a_talks = [
      %w[08:00:00 09:50:00 開始までしばらくお待ちください intermission],
      %w[09:50:00 10:00:00 オープニング intermission],
      #  10:00:00 12:00:00 Keynote
      %w[12:00:00 12:30:00 休憩 intermission],
      %w[12:30:00 13:00:00 スポンサーの想いが詰まった26のブース、あなたはどれを見る？ intermission],
      %w[13:00:00 13:20:00 休憩 intermission],
      #  13:20:00 14:00:00 CFP Session
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20:00 15:00:00 Breakout Sponsor
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20:00 16:00:00 CFP Session
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20:00 17:00:00 Breakout Sponsor
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20:00 18:00:00 CFP Session
      %w[18:00:00 19:00:00 クロージング intermission],
      %w[19:00:00 20:00:00 本日のイベントは終了しました intermission]
    ]

    other_track_talks = [
      %w[08:00:00 09:50:00 開始までしばらくお待ちください intermission],
      %w[09:50:00 10:00:00 トラックAでOP実施中！ intermission],
      %w[10:00:00 12:00:00 トラックAでキーノート配信中！ intermission],
      %w[12:00:00 12:30:00 休憩 intermission],
      %w[12:30:00 13:00:00 スポンサーの想いが詰まった26のブース、あなたはどれを見る？ intermission],
      %w[13:00:00 13:20:00 休憩 intermission],
      #  13:20:00 14:00:00 CFP Session
      %w[14:00:00 14:20:00 休憩 intermission],
      #  14:20:00 15:00:00 Breakout Sponsor
      %w[15:00:00 15:20:00 休憩 intermission],
      #  15:20:00 16:00:00 CFP Session
      %w[16:00:00 16:20:00 休憩 intermission],
      #  16:20:00 17:00:00 Breakout Sponsor
      %w[17:00:00 17:20:00 休憩 intermission],
      #  17:20:00 18:00:00 CFP Session
      %w[18:00:00 19:00:00 トラックAでクロージング実施中！ intermission],
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
    end
  end
end
