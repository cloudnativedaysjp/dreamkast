class Admin::TracksController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @date = params[:date] || @conference.conference_days.first.date.strftime("%Y-%m-%d")
    @track_name = params[:track_name] || @conference.tracks.first.name
    @track = @conference.tracks.find_by(name: @track_name)
    @talks = @conference.talks.where(conference_day_id: @conference.conference_days.find_by(date: @date).id, track_id: @track.id).order('conference_day_id ASC, start_time ASC, track_id ASC')
  end

  def update_tracks
    track = Track.find(params[:track][:id])
    track.video_id = params[:track][:video_id]

    respond_to do |format|
      if track.save && TalksHelper.update_talks(@conference, params[:video])
        format.js
      end
    end
  end

  private

  helper_method :active_date_tab?,
                :active_track_tab?,
                :on_air_url,
                :recording_url,
                :confirm_message,
                :alert_type,
                :recording?,
                :waiting_to_start?,
                :waiting_to_stop?,
                :recording_control_button_label,
                :already_recorded?

  def active_date_tab?(conference_day)
    conference_day.date.strftime("%Y-%m-%d") == @date
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

  def recording_url(talk)
    if recording?(talk)
      admin_stop_recording_path
    else
      admin_start_recording_path
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
    when 'danger'
      'danger'
    else
      'primary'
    end
  end

  def recording?(talk)
    media_live.present? &&
      media_live.recording_talk_id == talk.id &&
      media_live.status == 'channel_running'
  end

  def waiting_to_start?(talk)
    media_live.present? &&
      media_live.recording_talk_id == talk.id &&
      media_live.status == 'waiting_to_start'
  end

  def waiting_to_stop?(talk)
    media_live.present? &&
      media_live.recording_talk_id == talk.id &&
      media_live.status == 'waiting_to_stop'
  end

  def recording_control_button_label(talk)
    if media_live && media_live.recording_talk_id == talk.id && media_live.status == 'channel_running'
      'Recording'
    elsif media_live && media_live.recording_talk_id == talk.id && media_live.status == 'waiting_to_start'
      'Waiting to start recording'
    elsif media_live && media_live.recording_talk_id == talk.id && media_live.status == 'waiting_to_stop'
      'Waiting to stop recording'
    else
      'Start Record'
    end
  end

  def already_recorded?(talk)
    talk.video.video_id.present?
  end

  def media_live
    @track.live_stream_media_live
  end
end
