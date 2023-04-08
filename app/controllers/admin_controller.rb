class AdminController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def show
    @session = session
    @conference = Conference.find_by(abbr: event_name)
    @current = Video.on_air(@conference)
  end

  def accesslog
    # TODO: pagenation入れる
    @logs = AccessLog.all.order(id: 'DESC').limit(50)
  end

  def destroy_user
    @profile = Profile.find_by(sub: @current_user[:extra][:raw_info][:sub])
    @profile.destroy
    reset_session
    redirect_to(logout_url.to_s)
  end

  def users
    @profiles = Profile.where(conference_id: @conference.id)
  end

  def statistics
    @talks = @conference.talks.includes(:registered_talks).accepted.order('conference_day_id ASC, start_time ASC, track_id ASC')
    @tickets = @conference.tickets.includes(:check_ins)
  end

  def export_statistics
    f = Tempfile.create('statistics.csv')
    @conference = Conference.includes(talks: [:registered_talks]).find_by(abbr: params[:event])
    CSV.open(f.path, 'wb') do |csv|
      csv << %w[id item count]
      csv << ['', 'registered_user_count', Profile.where(conference_id: @conference.id).count]
      @conference.talks.each do |talk|
        csv << %W[#{talk.id} #{talk.title} #{talk.registered_talks.size}]
      end
    end
    send_file(f.path, filename: "statistics-#{Time.now.strftime("%F")}.csv", length: File.stat(f.path).size)
  end
end
