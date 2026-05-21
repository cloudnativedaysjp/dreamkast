class Admin::TracksController < ApplicationController
  include SecuredAdmin

  def index
    @conference = Conference.includes(:conference_days, :tracks).find_by(abbr: event_name)
    @date = params[:date] || @conference.conference_days.first.date.strftime('%Y-%m-%d')
    @conference_day = @conference.conference_days.select { |day| day.date.strftime('%Y-%m-%d') == @date }.first
    @track_name = params[:track_name] || @conference.tracks.first.name
    @track = @conference.tracks.find_by(name: @track_name)
    @talks = @conference
             .talks
             .includes(:speakers, :media_package_harvest_jobs, :proposal_items)
             .where(conference_day_id: @conference.conference_days.find_by(date: @date).id, track_id: @track.id)
             .order('conference_day_id ASC, start_time ASC, track_id ASC').includes(:video, :speakers, :conference_day, :track)
    @proposal_item_config_cache = ProposalItemConfig.where(conference_id: @conference.id).index_by(&:id)
    @has_presentation_method = @proposal_item_config_cache.values.any? { |c| c.label == 'presentation_method' }

    respond_to do |format|
      format.html
      format.js { render(:index) }
      format.turbo_stream
      format.csv { export_talks(@conference, @talks, @track_name, @date) }
    end
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

  def export_talks(conference, talks, track_name, date)
    head(:no_content)
    filepath = Talk.export_csv(conference, talks, track_name, date)
    stat = File.stat(filepath)
    send_file(filepath, filename: File.basename(filepath), length: stat.size)
  end
end
