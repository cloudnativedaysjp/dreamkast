class AdminController < ApplicationController
  include SecuredAdmin

  def show
    @session = session
    @conference = Conference.find_by(abbr: event_name)
    @current = Video.on_air(@conference)
  end

  def destroy_user
    @profile = Profile.find_by(sub: current_user[:extra][:raw_info][:sub])
    @profile.destroy
    redirect_to(logout_url)
  end

  def statistics
    @talks = @conference.talks.includes(registered_talks: :profile).accepted.order('conference_day_id ASC, start_time ASC, track_id ASC')
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
