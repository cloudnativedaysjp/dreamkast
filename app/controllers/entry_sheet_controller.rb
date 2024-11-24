class EntrySheetController < ApplicationController
  def show
    param = params[:encrypted]
    decrypted = ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base.byteslice(0..31)).decrypt_and_verify(Base64.urlsafe_decode64(param))
    max_rows = 10

    object = JSON.parse(decrypted)

    @profile = Profile.find(object['profile_id'])
    @speaker = object['speaker_id'].present? ? Speaker.find(object['speaker_id']) : nil
    @conference = Conference.find_by(abbr: params[:event])

    # 全てのテーブルの行数を取得
    @total_rows = @conference.conference_days.externals.sum do |conference_day|
      @profile.talks.where(conference_day:).count
    end

    # 縮小率を計算（最小0.5、最大1.0）
    @scale_factor = if @total_rows <= max_rows
                      1.0
                    else
                      max_scale = 1.0
                      min_scale = 0.5
                      scale = max_scale - ((@total_rows - max_rows) * 0.05)
                      [scale, min_scale].max
                    end

    render(
      'profiles/entry_sheet',
      layout: 'no_headers'
    )
  end
end
