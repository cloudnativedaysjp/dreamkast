class Admin::SponsorsController < ApplicationController
  include SecuredAdmin
  def new
    @sponsor_types = conference.sponsor_types
    @sponsor = Sponsor.new
    @sponsor_form = SponsorForm.new(sponsor: @sponsor)
    @sponsor_form.load
  end

  def index
    @sponsor_types = conference.sponsor_types.order(order: 'ASC')
    @sponsors = conference.sponsors
  end

  def show
    @sponsor = Sponsor.find(params[:id])
    @sponsor_contacts = @sponsor.sponsor_contacts
    @sponsor_contact_invites = @sponsor.sponsor_contact_invites
                                       .reject { |invite| invite.sponsor_contact_invite_accepts.present? }
                                       .group_by(&:email)
                                       .values
                                       .map { |invites| invites.max_by(&:expires_at) }
  end

  def edit
    @sponsor_types = conference.sponsor_types
    @sponsor = Sponsor.find(params[:id])
    @sponsor_form = SponsorForm.new(sponsor: @sponsor)
    @sponsor_form.load
  end

  def create
    @sponsor_types = conference.sponsor_types
    @sponsor_form = SponsorForm.new(sponsor_params, sponsor: Sponsor.new(conference:))

    if @sponsor_form.save
      flash.now[:notice] = "スポンサー #{@sponsor_form.sponsor.name} を登録しました"
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def update
    @sponsor = Sponsor.find(params[:id])
    @sponsor_types = conference.sponsor_types
    @sponsor_form = SponsorForm.new(sponsor_params, sponsor: @sponsor)

    if @sponsor_form.save
      flash.now.notice = "スポンサー #{@sponsor.name} を更新しました"
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @sponsor = Sponsor.find(params[:id])

    if @sponsor.destroy
      flash.now.notice = "スポンサー #{@sponsor.name} を削除しました"
    else
      flash.now.alert = "スポンサー #{@sponsor.name} の削除に失敗しました"
    end
  end

  private

  def sponsor_params
    params.require(:sponsor).permit(:id,
                                    :name,
                                    :abbr,
                                    :url,
                                    :description,
                                    :attachment_logo_image,
                                    sponsor_types: [])
  end
end
