require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_o11y2022'
  task add_talks_for_o11y2022: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    conference = Conference.find_by(abbr: 'o11y2022')
    conference_day = conference.conference_days.where(date: '2022-03-11').first
    track_a = conference.tracks.find_by(name: 'A')
    track_b = conference.tracks.find_by(name: 'B')
    track_c = conference.tracks.find_by(name: 'C')

    track_a_talks = [
      { start_time: '10:00:00', end_time: '12:00:00', title: '開始までお待ちください' },
      { start_time: '12:00:00', end_time: '12:05:00', title: 'Opening' },
      { start_time: '12:45:00', end_time: '13:05:00', title: '休憩' },
      { start_time: '13:45:00', end_time: '14:05:00', title: '休憩' },
      { start_time: '14:45:00', end_time: '15:05:00', title: '休憩' },
      { start_time: '15:45:00', end_time: '16:05:00', title: '休憩' },
      { start_time: '16:45:00', end_time: '17:05:00', title: '休憩' },
      { start_time: '17:45:00', end_time: '18:05:00', title: '休憩' },
      { start_time: '18:45:00', end_time: '19:00:00', title: 'Closing' },
      { start_time: '19:00:00', end_time: '20:00:00', title: 'Observability Conference 2022は終了しました' }
    ]

    track_b_talks = [
      { start_time: '10:00:00', end_time: '12:00:00', title: '開始までお待ちください' },
      { start_time: '12:00:00', end_time: '12:05:00', title: 'TrackAでOpeningセッション中' },
      { start_time: '12:45:00', end_time: '13:05:00', title: '休憩' },
      { start_time: '13:45:00', end_time: '14:05:00', title: '休憩' },
      { start_time: '14:45:00', end_time: '15:05:00', title: '休憩' },
      { start_time: '15:45:00', end_time: '16:05:00', title: '休憩' },
      { start_time: '16:45:00', end_time: '17:05:00', title: '休憩' },
      { start_time: '17:45:00', end_time: '18:05:00', title: '休憩' },
      { start_time: '18:45:00', end_time: '19:00:00', title: 'TrackAでClosingセッション中' },
      { start_time: '19:00:00', end_time: '20:00:00', title: 'Observability Conference 2022は終了しました' }
    ]

    track_c_talks = [
      { start_time: '10:00:00', end_time: '12:00:00', title: '開始までお待ちください' },
      { start_time: '12:00:00', end_time: '12:05:00', title: 'TrackAでOpeningセッション中' },
      { start_time: '12:45:00', end_time: '13:05:00', title: '休憩' },
      { start_time: '13:45:00', end_time: '14:05:00', title: '休憩' },
      { start_time: '14:45:00', end_time: '15:05:00', title: '休憩' },
      { start_time: '15:45:00', end_time: '16:05:00', title: '休憩' },
      { start_time: '16:45:00', end_time: '17:05:00', title: '休憩' },
      { start_time: '17:45:00', end_time: '18:05:00', title: '休憩' },
      { start_time: '18:45:00', end_time: '19:00:00', title: 'TrackAでClosingセッション中' },
      { start_time: '19:00:00', end_time: '20:00:00', title: 'Observability Conference 2022は終了しました' }
    ]

    track_a_talks.each do |param|
      add_intermission(conference, conference_day, track_a, param)
    end

    track_b_talks.each do |param|
      add_intermission(conference, conference_day, track_b, param)
    end

    track_c_talks.each do |param|
      add_intermission(conference, conference_day, track_c, param)
    end
  end

  def add_intermission(conference, conference_day, track, param)
    talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: conference_day.id, track_id: track.id, show_on_timetable: false, abstract: 'intermission'))
    talk.save!
    if talk.abstract != 'intermission'
      proposal = Proposal.new(conference_id: conference.id, talk_id: talk.id, status: 1)
      proposal.save!
    end
    video = Video.new(talk_id: talk.id, on_air: false)
    video.save!
  end
end
