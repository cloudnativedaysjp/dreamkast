require 'tempfile'

class Admin::SpeakersController < ApplicationController
  include SecuredAdmin

  def index
    @speakers = @conference.speakers
  end

  def edit
    @speaker = Speaker.find_by_id(params[:id])
    @speaker_form = SpeakerForm.new(speaker: @speaker, conference: @conference)
    @speaker_form.load
  end

  # PATCH/PUT admin/speakers/1
  # PATCH/PUT admin/speakers/1.json
  def update
    @speaker = Speaker.find(params[:id])

    @speaker_form = SpeakerForm.new(speaker_params, speaker: @speaker, conference: @conference)
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

  def export_speakers_for_website
    conference_days = @conference.conference_days.filter { |day| !day.internal }.map(&:id)
    query = { show_on_timetable: true, conference_id: @conference.id }

    @talks = Talk.includes([:conference, :conference_day, :talk_time, :talk_difficulty, :talk_category, :talks_speakers, :video, :speakers, :proposal]).where(query)
    @talks = if %w[cndt2020 cndo2021].include?(conference.abbr)
               @talks.left_joins(:talk_types)
                     .where.not(talk_types: { id: 'Intermission' })
                     .where.not(abstract: '-')
             else
               @talks.joins(:proposal)
                     .left_joins(:talk_types)
                     .where(proposals: { status: :accepted })
                     .where.not(talk_types: { id: 'Intermission' })
                     .where.not(abstract: '-')
             end
    @talks = @talks.where(conference_days.map { |id| "conference_day_id = #{id}" }.join(' OR '))
    @talks = @talks.select do |talk|
      if talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
        if talk.proposal_items.empty?
          false
        else
          proposal_item = talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL) || []
          proposal_item.proposal_item_configs.map { |config| [VideoAndSlidePublished::ALL_OK, VideoAndSlidePublished::ONLY_VIDEO].include?(config.key.to_i) }.any? && talk.archived?
        end
      else
        (talk.video_published && talk.video.present? && talk.archived?)
      end
    end

    @speakers = @talks.map(&:speakers).flatten.uniq

    respond_to do |format|
      format.json do
        json_str = render_to_string(template: 'admin/speakers/export_speakers_for_website')
        json_obj = JSON.parse(json_str)
        formatted_json = JSON.pretty_generate(json_obj)

        filename = Tempfile.new(["#{@conference.abbr}_speakers", '.json']).path
        File.write(filename, formatted_json)

        stat = File.stat(filename)
        send_file(filename, filename: "#{@conference.abbr}_speakers.json", length: stat.size)
      end
    end
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
                                    :additional_documents,
                                    talks_attributes:)
  end

  def talks_attributes
    attr = [:id, :title, :abstract, :document_url, :conference_id, :_destroy, :talk_category_id, :talk_difficulty_id, :talk_time_id, :sponsor_id]
    h = {}
    @conference.proposal_item_configs.map(&:label).uniq.each do |label|
      conf = @conference.proposal_item_configs.find_by(label:)
      if conf.instance_of?(::ProposalItemConfigCheckBox)
        h[conf.label.pluralize.to_sym] = []
      elsif conf.instance_of?(::ProposalItemConfigRadioButton)
        attr << conf.label.pluralize.to_sym
      end
    end
    attr.append(h)
  end

  helper_method :speaker_url, :session_type_name, :speaker_check_in_status

  def speaker_url
    case action_name
    when 'new'
      "/#{params[:event]}/admin/speakers"
    when 'edit', 'update'
      "/#{params[:event]}/admin/speakers/#{params[:id]}"
    end
  end

  def session_type_name(talk)
    if talk.keynote?
      'Keynote'
    elsif talk.sponsor_session?
      'スポンサー'
    else
      'CFP'
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
