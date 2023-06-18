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
          start_time: '11:00:00',
          end_time: '11:20:00',
          abstract: <<~EOS
            Keynote Speaker 1
          EOS
        },
        {
          title: 'Keynote 2',
          start_time: '11:25:00',
          end_time: '11:45:00',
          abstract: <<~EOS
            Keynote Speaker 2
          EOS
        },
        {
          title: 'Keynote 3',
          start_time: '11:50:00',
          end_time: '12:10:00',
          abstract: <<~EOS
            Keynote Speaker 3
          EOS
        },
        {
          title: 'Keynote 4',
          start_time: '12:15:00',
          end_time: '12:35:00',
          abstract: <<~EOS
            Keynote Speaker 4
          EOS
        },
        {
          title: 'Keynote 5',
          start_time: '12:40:00',
          end_time: '13:00:00',
          abstract: <<~EOS
            Diamond Sponsor
          EOS
        },
        {
          title: 'A1',
          start_time: '14:00:00',
          end_time: '14:40:00',
          abstract: <<~EOS
            A1
          EOS
        },
        {
          title: 'A2',
          start_time: '15:00:00',
          end_time: '15:40:00',
          abstract: <<~EOS
            A2
          EOS
        },
        {
          title: 'A3',
          start_time: '16:00:00',
          end_time: '16:40:00',
          abstract: <<~EOS
            A3
          EOS
        },
        {
          title: 'A4',
          start_time: '17:00:00',
          end_time: '17:40:00',
          abstract: <<~EOS
            A4
          EOS
        },
        {
          title: 'A5',
          start_time: '18:00:00',
          end_time: '18:40:00',
          abstract: <<~EOS
            A5
          EOS
        }
      ],
      B: [
        {
          title: 'B1',
          start_time: '14:00:00',
          end_time: '14:40:00',
          abstract: <<~EOS
            B1
          EOS
        },
        {
          title: 'B2',
          start_time: '15:00:00',
          end_time: '15:40:00',
          abstract: <<~EOS
            B2
          EOS
        },
        {
          title: 'B3',
          start_time: '16:00:00',
          end_time: '16:40:00',
          abstract: <<~EOS
            B3
          EOS
        },
        {
          title: 'B4',
          start_time: '17:00:00',
          end_time: '17:40:00',
          abstract: <<~EOS
            B4
          EOS
        },
        {
          title: 'B5',
          start_time: '18:00:00',
          end_time: '18:40:00',
          abstract: <<~EOS
            B5
          EOS
        }
      ],
      C: [
        {
          title: 'C1',
          start_time: '14:00:00',
          end_time: '14:40:00',
          abstract: <<~EOS
            C1
          EOS
        },
        {
          title: 'C2',
          start_time: '15:00:00',
          end_time: '15:40:00',
          abstract: <<~EOS
            C2
          EOS
        },
        {
          title: 'C3',
          start_time: '16:00:00',
          end_time: '16:40:00',
          abstract: <<~EOS
            C3
          EOS
        },
        {
          title: 'C4',
          start_time: '17:00:00',
          end_time: '17:40:00',
          abstract: <<~EOS
            C4
          EOS
        },
        {
          title: 'C5',
          start_time: '18:00:00',
          end_time: '18:40:00',
          abstract: <<~EOS
            C5
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
