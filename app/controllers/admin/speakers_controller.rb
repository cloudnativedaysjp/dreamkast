class Admin::SpeakersController < ApplicationController
  include SecuredAdmin

  def index
    @speakers = @conference.speakers
  end

  def edit
    @speaker = Speaker.find_by_id(params[:id])
    @speaker_form = SpeakerForm.new(speaker: @speaker)
    @speaker_form.load
  end

  # PATCH/PUT admin/speakers/1
  # PATCH/PUT admin/speakers/1.json
  def update
    @speaker = Speaker.find(params[:id])

    @speaker_form = SpeakerForm.new(speaker_params, speaker: @speaker)
    @speaker_form.sub = @speaker.sub
    @speaker_form.email = @speaker.email

    respond_to do |format|
      if @speaker_form.save
        format.html { redirect_to(admin_speakers_path, notice: "Speaker #{@speaker.name} (id: #{@speaker.id})was successfully updated.") }
        format.json { render(:show, status: :ok, location: @speaker) }
      else
        format.html { render(:edit) }
        format.json { render(json: @speaker.errors, status: :unprocessable_entity) }
      end
    end
  end

  def export_speakers
    all = Speaker.export
    filename = './tmp/speaker.csv'
    File.open(filename, 'w') do |file|
      file.write(all)
    end
    # ダウンロード
    stat = File.stat(filename)
    send_file(filename, filename: "speaker-#{Time.now.strftime("%F")}.csv", length: stat.size)
  end

  def check_in_statuses
    @speakers = @conference.speakers
    @talks = @speakers.map { |speaker| speaker.talks.accepted }.flatten

    respond_to do |format|
      format.html { render(:'admin/speakers/speaker_check_in_statues') }
    end
  end

  private

  def speaker_params
    params.require(:speaker).permit(:name,
                                    :name_mother_tongue,
                                    :sub,
                                    :email,
                                    :profile,
                                    :company,
                                    :job_title,
                                    :twitter_id,
                                    :github_id,
                                    :avatar,
                                    :conference_id,
                                    talks_attributes: [:id, :title, :abstract, :conference_id, :_destroy, :talk_category_id, :talk_time_id])
  end

  helper_method :speaker_url, :session_type_name, :speaker_check_in_status

  def speaker_url
    case action_name
    when 'new'
      "/#{params[:event]}/admin/speaker"
    when 'edit'
      "/#{params[:event]}/admin/speakers/#{params[:id]}"
    end
  end

  def session_type_name(talk)
    case talk.type
    when 'Session'
      'CFP'
    when 'Keynote'
      'Keynote'
    when 'SponsorSession'
      'スポンサー'
    else
      ''
    end
  end

  def speaker_check_in_status(speaker)
    if speaker.attendee_profile&.check_in_conferences&.order(check_in_timestamp: :asc)&.first.present?
      speaker.attendee_profile&.check_in_conferences&.order(check_in_timestamp: :asc)&.first&.check_in_timestamp
    else
      '未チェックイン'
    end
  end
end
