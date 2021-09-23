class Admin::VideoRegistrationsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def bulk_update
    params[:video_registration].each do |id, value|
      puts "id: #{id}"
      puts "value: #{value}"

      video_registration = VideoRegistration.find(id)
      old = video_registration.status
      now = VideoRegistration.statuses[value.to_i]
      video_registration.status = value.to_i

      if video_registration.save
        # 確認済みに変更した時のみ通知する
        if value.to_i == 2
          # TODO: 非同期化すること！！！
          begin
            speaker = Speaker.find_by(conference: @conference.id, email: @current_user[:info][:email])
            talk = video_registration.talk
            SpeakerMailer.video_uploaded(speaker, talk, @video_registration).deliver_now
          rescue => e
            logger.error "Failed to send mail: #{e.message}"
          end
        end
      end
    end
    redirect_to admin_videos_path, notice: "配信設定を更新しました"
  end
end
