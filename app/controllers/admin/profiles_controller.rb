class Admin::ProfilesController < ApplicationController
  include SecuredAdmin

  def index
    @query = params[:q].to_s.strip
    @profiles = Profile.where(conference_id: @conference.id)
                       .search_by_name_or_email(@query)
                       .includes(:check_in_conferences)
                       .order(:id)
                       .page(params[:page])
                       .per(50)
  end

  def export_profiles
    profiles = Profile.export(@conference.id)
    filename = './tmp/profiles.csv'
    File.open(filename, 'w') do |file|
      file.write(profiles)
    end
    # ダウンロード
    stat = File.stat(filename)
    send_file(filename, filename: "profiles-#{Time.now.strftime("%F")}.csv", length: stat.size)
  end

  def entry_sheet
    @profile = current_conference.profiles.find(params[:id])
    @speaker = current_conference.speakers.find_by(user_id: @profile.user_id)

    render('profiles/entry_sheet')
  end
end
