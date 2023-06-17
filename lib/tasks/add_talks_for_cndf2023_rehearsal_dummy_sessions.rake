require 'slack/incoming/webhooks'

namespace :util do
  desc 'add_talks_for_cndf2023_rehearsal_dummy_sessions'
  task add_talks_for_cndf2023_rehearsal_dummy_sessions: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG
    conference = Conference.find_by(abbr: 'cndf2023')
    rehearsal_day = conference.conference_days.find_by(date: '2023-06-22')

    talk_map = {
      A: [
        {
          title: 'Keynote 1',
          start_time: '12:00:00',
          end_time: '12:20:00',
          abstract: <<~EOS
            これは キーノート 1 です。
          EOS
        },
        {
          title: 'Keynote 2',
          start_time: '12:25:00',
          end_time: '12:45:00',
          abstract: <<~EOS
            これは キーノート 2 です。
          EOS
        },
        {
          title: 'Keynote 3',
          start_time: '12:50:00',
          end_time: '13:10:00',
          abstract: <<~EOS
            これは キーノート 3 です。
          EOS
        },
        {
          title: 'Keynote 4',
          start_time: '13:15:00',
          end_time: '13:35:00',
          abstract: <<~EOS
            これは キーノート 4 です。
          EOS
        },
        {
          title: 'Keynote 5',
          start_time: '13:40:00',
          end_time: '14:00:00',
          abstract: <<~EOS
            これは キーノート 5 です。
          EOS
        },
        {
          title: 'Session 1 (for track A)',
          start_time: '14:20:00',
          end_time: '15:00:00',
          abstract: <<~EOS
            これは トラック A の セッション 1 です。
          EOS
        },
        {
          title: 'Session 2 (for track A)',
          start_time: '15:20:00',
          end_time: '16:00:00',
          abstract: <<~EOS
            これは トラック A の セッション 2 です。
          EOS
        }
      ],
      B: [
        {
          title: 'Session 1 (for track B)',
          start_time: '14:20:00',
          end_time: '15:00:00',
          abstract: <<~EOS
            これは トラック B の セッション 1 です。
          EOS
        },
        {
          title: 'Session 2 (for track B)',
          start_time: '15:20:00',
          end_time: '16:00:00',
          abstract: <<~EOS
            これは トラック B の セッション 2 です。
          EOS
        }
      ],
      C: [
        {
          title: 'Session 1 (for track C)',
          start_time: '14:20:00',
          end_time: '15:00:00',
          abstract: <<~EOS
            これは トラック C の セッション 1 です。
          EOS
        },
        {
          title: 'Session 2 (for track C)',
          start_time: '15:20:00',
          end_time: '16:00:00',
          abstract: <<~EOS
            これは トラック C の セッション 2 です。
          EOS
        }
      ]
    }

    talk_map.each do |track_name, talks|
      track = conference.tracks.find_by(name: track_name.to_s)
      talks.each do |param|
        talk = Talk.new(param.merge(conference_id: conference.id, conference_day_id: rehearsal_day.id, track_id: track.id, show_on_timetable: true))
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
end
