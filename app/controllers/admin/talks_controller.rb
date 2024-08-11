class Admin::TalksController < ApplicationController
  include SecuredAdmin

  def index
    @talks = @conference.talks.accepted_and_intermission.order('conference_day_id ASC, start_time ASC, track_id ASC')
    respond_to do |format|
      format.html
      format.csv do
        head(:no_content)

        filepath = Talk.export_csv(@conference, @talks)
        stat = File.stat(filepath)
        send_file(filepath, filename: File.basename(filepath), length: stat.size)
      end
    end
  end

  def update_talks
    TalksHelper.update_talks(@conference, params[:video])

    redirect_to(admin_talks_url, notice: '配信設定を更新しました')
  end

  def start_on_air
    @talk = Talk.find(params[:talk][:id])

    respond_to do |format|
      on_air_talks_of_other_days = @talk.track.talks.includes([:conference_day, :video]).accepted_and_intermission.reject { |t| t.conference_day.id == @talk.conference_day.id }.select { |t| t.video.on_air? }
      if on_air_talks_of_other_days.size.positive?
        format.turbo_stream {
          flash[:alert] = "Talk id=#{on_air_talks_of_other_days.map(&:id).join(',')} are already on_air."
          # render(partial: 'admin/tracks/partial/on_air_button', locals: { talk: @talk })
        }
      else
        @talk.start_streaming
        format.turbo_stream {
          flash[:notice] = "OnAirに切り替えました: #{@talk.start_to_end} #{@talk.speaker_names.join(',')} #{@talk.title}"
          # render(partial: 'admin/tracks/partial/on_air_button', locals: { talk: @talk })
        }
      end
    end
  end

  def stop_on_air
    @talk = Talk.find(params[:talk][:id])
    @talk.stop_streaming

    respond_to do |format|
      format.turbo_stream {
        flash.now[:notice] = "Waitingに切り替えました: #{@talk.start_to_end} #{@talk.speaker_names.join(',')} #{@talk.title}"
        # render(partial: 'admin/tracks/partial/on_air_button', locals: { talk: @talk })
      }
    end
  end
end
