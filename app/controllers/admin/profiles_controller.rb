class Admin::ProfilesController < ApplicationController
  include Secured

  before_action :is_admin?, :set_conference

  def export_profiles
    profiles = Profile.export(@conference.id)
    filename = "./tmp/profiles.csv"
    File.open(filename, 'w') do |file|
      file.write(profiles)
    end
    # ダウンロード
    stat = File::stat(filename)
    send_file(filename, :filename => "profiles-#{Time.now.strftime("%F")}.csv", :length => stat.size)
  end
end
