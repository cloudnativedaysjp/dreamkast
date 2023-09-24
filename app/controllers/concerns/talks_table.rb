module TalksTable
  extend ActiveSupport::Concern

  included do
    helper_method :active_date_tab?,
                  :active_track_tab?,
                  :on_air_url,
                  :confirm_message,
                  :alert_type,
                  :already_recorded?
  end

  def active_date_tab?(conference_day)
    conference_day.date.strftime('%Y-%m-%d') == @date
  end

  def active_track_tab?(track)
    track.name == @track_name
  end

  def on_air_url(talk)
    if talk.video.on_air
      admin_stop_on_air_path
    else
      admin_start_on_air_path
    end
  end

  def confirm_message(talk)
    if talk.video.on_air?
      "Waitingに切り替えます:\n#{talk.speaker_names.join(',')} #{talk.title}"
    else
      "OnAirに切り替えます:\n#{talk.speaker_names.join(',')} #{talk.title}"
    end
  end

  def alert_type(message_type)
    case message_type
    when 'notice'
      'success'
    when 'danger', 'alert'
      'danger'
    else
      'primary'
    end
  end

  def already_recorded?(talk)
    talk.video.video_id.present?
  end

  def media_live
    @track.live_stream_media_live
  end
end
