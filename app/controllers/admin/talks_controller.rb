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
               @talks.where.not(abstract: 'intermission').where.not(abstract: '-')
             else
               @talks.where(proposals: { status: :accepted }).where.not(abstract: 'intermission').where.not(abstract: '-')
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

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
