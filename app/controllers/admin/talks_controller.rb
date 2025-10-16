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

  def edit
    @talk = Talk.includes(:proposal_items, :talk_types).find(params[:id])
    @talk_categories = TalkCategory.where(conference_id: @conference.id)
    @talk_difficulties = TalkDifficulty.where(conference_id: @conference.id)
    @tracks = Track.where(conference_id: @conference.id)
    @conference_days = ConferenceDay.where(conference_id: @conference.id)
    @talk_types = TalkType.ordered
    # ProposalItemsを強制的にリロード
    @talk.proposal_items.reload
  end

  def update
    @talk = Talk.includes(:proposal_items, :talk_types).find(params[:id])

    if update_talk_with_proposal_items
      redirect_to(admin_talks_path(event: params[:event]), notice: 'セッションを更新しました')
    else
      @talk_categories = TalkCategory.where(conference_id: @conference.id)
      @talk_difficulties = TalkDifficulty.where(conference_id: @conference.id)
      @tracks = Track.where(conference_id: @conference.id)
      @conference_days = ConferenceDay.where(conference_id: @conference.id)
      @talk_types = TalkType.ordered
      render(:edit)
    end
  end

  def update_talks
    TalksHelper.update_talks(@conference, params[:video])

    redirect_to(admin_talks_url, notice: '配信設定を更新しました')
  end

  def start_on_air
    @talk = Talk.find(params[:talk][:id])
    on_air_talks_of_other_days = @talk.track.talks
                                      .includes([:conference_day, :video])
                                      .accepted_and_intermission
                                      .where.not(conference_days: { id: @talk.conference_day.id })
                                      .joins(:video)
                                      .where(videos: { on_air: true })


    if on_air_talks_of_other_days.size.positive?
      flash.now.alert = "別日(#{on_air_talks_of_other_days.map(&:conference_day).map(&:date).join(',')})にオンエアのセッションが残っています: #{on_air_talks_of_other_days.map(&:id).join(',')}"
    else
      @current_on_air_videos = @talk.track.talks.includes([:track, :video, :speakers, :conference_day]).where.not(id: @talk.id).joins(:video).map(&:video)
      ActiveRecord::Base.transaction do
        # Disable onair of all talks that are onair
        @current_on_air_videos.each do |video|
          video.update!(on_air: false)
        end

        # Update the current talk to onair
        @talk.video.update!(on_air: true)
      end

      ActionCable.server.broadcast(
        "on_air_#{conference.abbr}", Video.on_air_v2(conference.id)
      )
      flash.now.notice = "OnAirに切り替えました: #{@talk.start_to_end} #{@talk.speaker_names.join(',')} #{@talk.title}"
    end
  end

  def stop_on_air
    @talk = Talk.find(params[:talk][:id])
    @talk.video.update!(on_air: false)
    ActionCable.server.broadcast(
      "on_air_#{conference.abbr}", Video.on_air_v2(conference.id)
    )

    flash.now.notice = "Waitingに切り替えました: #{@talk.start_to_end} #{@talk.speaker_names.join(',')} #{@talk.title}"
  end

  def export_talks_for_website
    query = { show_on_timetable: true, conference_id: conference.id }
    @talks = Talk.includes([:conference, :conference_day, :talk_time, :talk_difficulty, :talk_category, :talks_speakers, :video, :speakers, :proposal]).where(query)
    @talks = if %w[cndt2020 cndo2021].include?(conference.abbr)
               # Exclude intermission talks for older conferences using join
               @talks.left_joins(:talk_types)
                     .where.not(talk_types: { id: 'Intermission' })
                     .where.not(abstract: '-')
             else
               # For newer conferences, check both acceptance and intermission exclusion
               @talks.joins(:proposal)
                     .left_joins(:talk_types)
                     .where(proposals: { status: :accepted })
                     .where.not(talk_types: { id: 'Intermission' })
                     .where.not(abstract: '-')
             end
    conference_days = conference.conference_days.filter { |day| !day.internal }.map(&:id)
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
        json_str = render_to_string(template: 'admin/talks/export_talks_for_website')
        json_obj = JSON.parse(json_str)
        formatted_json = JSON.pretty_generate(json_obj)

        filename = Tempfile.new(["#{@conference.abbr}_talks", '.json']).path
        File.write(filename, formatted_json)

        stat = File.stat(filename)
        send_file(filename, filename: "#{@conference.abbr}_talks.json", length: stat.size)
      end
    end
  end

  helper_method :turbo_stream_flash

  private

  def talk_params
    params.require(:talk).permit(
      :title, :abstract, :talk_category_id, :talk_difficulty_id,
      :track_id, :conference_day_id, :start_time, :end_time,
      :show_on_timetable, :video_published, :document_url, :ogp_image_url,
      talk_type_ids: []
    )
  end

  def update_talk_with_proposal_items
    ActiveRecord::Base.transaction do
      # Talkの基本情報を更新
      @talk.update!(talk_params)

      # Proposal itemsを処理
      process_proposal_items

      # buildされたProposalItemsを保存
      @talk.save!

      true
    end
  rescue => e
    Rails.logger.error("Failed to update talk: #{e}")
    @talk.errors.add(:base, "更新に失敗しました: #{e.message}")
    false
  end

  def process_proposal_items
    proposal_item_config_labels.each do |label|
      value = params[:talk][label.to_sym]
      next unless value.present?

      # チェックボックス（配列）の場合とラジオボタン（単一値）の場合を処理
      processed_value = if value.is_a?(Array)
                          value.reject(&:blank?)
                        else
                          value
                        end

      @talk.create_or_update_proposal_item(label, processed_value) if processed_value.present?
    end
  end

  def proposal_item_config_labels
    @proposal_item_config_labels ||= @conference.proposal_item_configs.map(&:label).uniq
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
