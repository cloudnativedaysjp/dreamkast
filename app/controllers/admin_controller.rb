class AdminController < ApplicationController
  include SecuredAdmin

  def show
    @session = session
    @current = Video.on_air(current_conference)
    @offline_registrants_count = current_conference.profiles.offline.count
    @online_registrants_count = current_conference.profiles.online.count
    @checked_in_count = current_conference.check_in_conferences.count
    # TODO: 実際のオンライン視聴者数を取得できるようになったら置き換える
    @online_viewers_count = 1234
  end

  def destroy_user
    @profile = Profile.find_by(user_id: current_user_model.id)
    @profile.destroy
    redirect_to(logout_url)
  end

  def statistics
    @talks = @conference.talks.includes(:check_in_talks, registered_talks: :profile).accepted.order('conference_day_id ASC, start_time ASC, track_id ASC')
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
