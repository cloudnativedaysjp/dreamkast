class Admin::ProfilesController < ApplicationController
  include SecuredAdmin

  def index
    @profiles = Profile.where(conference_id: @conference.id)
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
    @profile = Profile.find(params[:id])
    @speaker = conference.speakers.find_by(sub: @profile.sub)

    render('profiles/entry_sheet')
  end
end
