namespace :db do
  desc "add_non_schedule_session_to_cndo2021"

  def create_or_update(title, date, conference)
    talk = Talk.where("title = ?", title)
    track = Track.find_by(name: title[-1], conference_id: conference.id)
    attr = {
      title: title,
      abstract: title[-1],
      conference_id: conference.id,
      conference_day_id: conference.conference_days.find_by(date: date).id,
      date: date,
      show_on_timetable: false,
      track_id: track.id,
      start_time: Time.parse("01:00"), # UTC
      end_time: Time.parse("10:30"), # UTC
      talk_difficulty_id: 11,
      talk_category_id: 35,
      talk_time_id: 6
    }
    if Talk.where("title = ?", title).exists?
      talk.update(attr)
    else
      talk = Talk.create!(attr)
      Video.create!(talk_id: talk.id, on_air: false)
    end
  end

  task add_non_schedule_session_to_cndo2021: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    ActiveRecord::Base.transaction do
      begin
        conference = Conference.find_by(abbr: "cndo2021")
        [
          "CloudNative Days Online 2021 Day1 Track A",
          "CloudNative Days Online 2021 Day1 Track B",
          "CloudNative Days Online 2021 Day1 Track C",
          "CloudNative Days Online 2021 Day1 Track D",
          "CloudNative Days Online 2021 Day1 Track E",
          "CloudNative Days Online 2021 Day1 Track F",
          "CloudNative Days Online 2021 Day1 Track G",
        ].each do |title|
          create_or_update(title, "2021-03-11", conference)
        end

        [
          "CloudNative Days Online 2021 Day2 Track A",
          "CloudNative Days Online 2021 Day2 Track B",
          "CloudNative Days Online 2021 Day2 Track C",
          "CloudNative Days Online 2021 Day2 Track D",
          "CloudNative Days Online 2021 Day2 Track E",
          "CloudNative Days Online 2021 Day2 Track F",
          "CloudNative Days Online 2021 Day2 Track G",
        ].each do |title|
          create_or_update(title, "2021-03-12", conference)
        end
      rescue => e
        puts(e)
      end
    end
  end
end
