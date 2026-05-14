class AdminController < ApplicationController
  include SecuredAdmin

  def show
    @session = session
    @current = Video.on_air(current_conference)
    @offline_registrants_count = current_conference.profiles.offline.count
    @online_registrants_count = current_conference.profiles.online.count
    @checked_in_count = current_conference.check_in_conferences
                                          .joins(:profile)
                                          .merge(Profile.offline)
                                          .distinct
                                          .count(:profile_id)
    @online_viewers_count = OnlineViewerStats.new(current_conference).unique_viewers_count
  end

  def destroy_user
    @profile = Profile.find_by(user_id: current_user_model.id)
    @profile.destroy
    redirect_to(logout_url)
  end

  def statistics
    @talks = @conference.talks.accepted.order('conference_day_id ASC, start_time ASC, track_id ASC')
    talk_ids = @talks.pluck(:id)

    participation_counts = RegisteredTalk.joins(:profile)
                                         .where(talk_id: talk_ids)
                                         .group(:talk_id, 'profiles.participation')
                                         .count
    @online_counts_by_talk  = Hash.new(0)
    @offline_counts_by_talk = Hash.new(0)
    participation_counts.each do |(tid, participation), count|
      case participation
      when Profile.participations[:online]  then @online_counts_by_talk[tid]  = count
      when Profile.participations[:offline] then @offline_counts_by_talk[tid] = count
      end
    end

    @online_viewers_by_talk = OnlineViewerStats.new(@conference).viewer_counts_by_talk || {}
    @check_in_counts_by_talk = CheckInTalk.where(talk_id: talk_ids)
                                          .group(:talk_id)
                                          .distinct
                                          .count(:profile_id)
  end

  def export_statistics
    f = Tempfile.create('statistics.csv')
    @conference = Conference.includes(talks: [registered_talks: :profile]).find_by(abbr: params[:event])
    CSV.open(f.path, 'wb') do |csv|
      csv << %w[id item online_participation_size offline_participation_size]
      @conference.talks.accepted.each do |talk|
        csv << %W[#{talk.id} #{talk.title} #{talk.online_participation_size} #{talk.offline_participation_size}]
      end
    end
    send_file(f.path, filename: "statistics-#{Time.now.strftime("%F")}.csv", length: File.stat(f.path).size)
  end
end
