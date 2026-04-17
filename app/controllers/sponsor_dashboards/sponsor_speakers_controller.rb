class SponsorDashboards::SponsorSpeakersController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact
  before_action :ensure_speaker_belongs_to_sponsor, only: [:edit, :update, :destroy]

  def index
    @conference = Conference.find_by(abbr: params[:event])
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]
    @sponsor_speakers = @sponsor.speakers
    @sponsor_speaker_invites = @sponsor.sponsor_speaker_invites
                                       .reject { |invite| invite.sponsor_speaker_invite_accepts.present? }
                                       .group_by(&:email)
                                       .values
                                       .map { |invites| invites.max_by(&:expires_at) }
  end

  # GET /:event/speaker_dashboard/:sponsor_id/speakers/:id/edit
  def edit
    @sponsor = Sponsor.find(params[:sponsor_id]) if params[:sponsor_id]

    @speaker = Speaker.find_by(conference_id: @conference.id, id: params[:id])
    # authorize(@speaker)
  end

  # PATCH/PUT /:event/sponsor_dashboards/:sponsor_id/speakers/:id
  def update
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.find(params[:id])

    if @speaker.update(speaker_params)
      flash.now[:notice] = 'スポンサー登壇者を更新しました'
    else
      flash.now[:alert] = 'スポンサー登壇者の更新に失敗しました'
      render(:edit, status: :unprocessable_entity)
    end
  end

  # DELETE /:event/sponsor_dashboards/:sponsor_id/speakers/:id
  # Speaker 本体は削除せず、このスポンサーとの紐付け（sponsor_id と
  # SponsorSpeakerInviteAccept）のみを解除する。Speaker は他のスポンサーや
  # 通常プロポーザルからも参照されうるため。
  def destroy
    @sponsor = Sponsor.find(params[:sponsor_id])
    @speaker = Speaker.find(params[:id])

    ActiveRecord::Base.transaction do
      @sponsor.sponsor_speaker_invite_accepts.where(speaker_id: @speaker.id).destroy_all
      @speaker.update!(sponsor_id: nil) if @speaker.sponsor_id == @sponsor.id
    end

    @sponsor_speakers = @sponsor.speakers
    @sponsor_speaker_invites = @sponsor.sponsor_speaker_invites
    flash.now[:notice] = 'スポンサー登壇者から外しました'
  rescue ActiveRecord::RecordInvalid
    flash.now[:alert] = 'スポンサー登壇者の削除に失敗しました'
  end

  private

  helper_method :speaker_url, :expected_participant_params, :execution_phases_params, :turbo_stream_flash

  def speaker_url
    case action_name
    when 'edit', 'update'
      "/#{params[:event]}/sponsor_dashboards/#{params[:sponsor_id]}/speakers/#{params[:id]}"
    end
  end

  def pundit_user
    if current_user && current_user_model
      Speaker.find_by(conference_id: @conference.id, user_id: current_user_model.id)
    end
  end

  def expected_participant_params
    @conference.proposal_item_configs.where(label: 'expected_participant')
  end

  def execution_phases_params
    @conference.proposal_item_configs.where(label: 'execution_phase')
  end

  # Only allow a list of trusted parameters through.
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
                                    :sponsor_id,
                                    :avatar,
                                    :conference_id,
                                    :additional_documents)
  end

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end

  def set_sponsor_contact
    @conference ||= Conference.find_by(abbr: params[:event])
    if current_user && current_user_model
      @sponsor_contact = SponsorContact.find_by(conference_id: @conference.id, user_id: current_user_model.id)
    end
  end

  def ensure_speaker_belongs_to_sponsor
    sponsor = Sponsor.find(params[:sponsor_id])
    unless sponsor.speakers.exists?(id: params[:id])
      render_404
    end
  end
end
