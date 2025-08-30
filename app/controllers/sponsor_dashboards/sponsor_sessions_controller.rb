class SponsorDashboards::SponsorSessionsController < ApplicationController
  include SecuredSponsor
  before_action :set_sponsor_contact

  def index
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_contacts = @sponsor.sponsor_contacts
    @sponsor_sessions = @sponsor.talks
    @sponsor_speakers = @sponsor.speakers
  end

  def new
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_session = Talk.new
    @sponsor_session_form = SponsorSessionForm.new(sponsor_session: @sponsor_session, conference:)
    @sponsor_speakers = @sponsor.speakers
  end

  def create
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_session = Talk.new(conference:, sponsor: @sponsor)
    @sponsor_session_form = SponsorSessionForm.new(sponsor_session_params, sponsor_session: @sponsor_session, conference:)
    if @sponsor_session_form.save
      flash.now[:notice] = 'スポンサーセッションを登録しました'
    else
      @sponsor_speakers = @sponsor.speakers
      flash.now[:alert] = 'スポンサーセッションの登録に失敗しました'
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_session = Talk.find(params[:id])
    @sponsor_session_form = SponsorSessionForm.new(sponsor_session: @sponsor_session, conference:)
    @sponsor_session_form.load
    @sponsor_speakers = @sponsor.speakers
  end

  def update
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_session = Talk.find(params[:id])
    @sponsor_session_form = SponsorSessionForm.new(sponsor_session_params, sponsor_session: @sponsor_session, conference:)
    if @sponsor_session_form.save
      flash.now[:notice] = 'スポンサーセッションを更新しました'
    else
      @sponsor_speakers = @sponsor.speakers
      flash.now[:alert] = 'スポンサーセッションの更新に失敗しました'
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @sponsor = Sponsor.find(params[:sponsor_id])
    @sponsor_session = Talk.find(params[:id])
    @sponsor_session_form = SponsorSessionForm.new(sponsor_session: @sponsor_session, conference:)
    if @sponsor_session.destroy
      flash.now[:notice] = 'スポンサーセッションを削除しました'
    else
      @sponsor_speakers = @sponsor.speakers
      flash.now[:alert] = 'スポンサーセッションの削除に失敗しました'
      render(:new, status: :unprocessable_entity)
    end
  end

  helper_method :turbo_stream_flash

  private

  def sponsor_session_params
    talk_params = params.require(:talk).permit(
      :sponsor_id,
      :conference_id,
      :title,
      :abstract,
      :talk_category_id,
      :talk_difficulty_id,
      :document_url,
      speaker_ids: []
    )

    sponsor_session_params = params[:sponsor_session]&.permit(proposal_items_attributes:)

    merged_params = talk_params.to_h
    if sponsor_session_params && sponsor_session_params[:proposal_items_attributes]
      merged_params[:proposal_items_attributes] = sponsor_session_params[:proposal_items_attributes]
    end

    merged_params
  end

  def proposal_items_attributes
    attr = []
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

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end

  def set_sponsor_contact
    @conference ||= Conference.find_by(abbr: params[:event])
    if current_user
      @sponsor_contact = SponsorContact.find_by(conference_id: @conference.id, email: current_user[:info][:email])
    end
  end
end
