class ProfilesController < ApplicationController
  include Secured

  before_action :set_conference
  before_action :set_current_profile, only: [:edit, :update, :destroy]
  skip_before_action :logged_in_using_omniauth?, only: [:new]
  before_action :is_admin?, :find_profile, only: [:destroy_id, :set_role]

  def new
    @profile = Profile.new
    @conference = Conference.find_by(abbr: params[:event])
    if set_current_user && Profile.find_by(conference_id: @conference.id, email: @current_user[:info][:email])
      redirect_to(dashboard_path)
    end
    @event = params[:event]
  end

  def edit
  end

  def create
    postal_code = profile_params[:company_postal_code].gsub(/-/, '')
    tel = profile_params[:company_tel].gsub(/-/, '')

    @profile = Profile.new(profile_params.merge(conference_id: @conference.id, company_postal_code: postal_code, company_tel: tel))
    @profile.sub = @current_user[:extra][:raw_info][:sub]
    @profile.email = @current_user[:info][:email]

    if @profile.save
      Agreement.create!(profile_id: @profile.id, form_item_id: 1, value: 1) if agreement_params['require_email']
      Agreement.create!(profile_id: @profile.id, form_item_id: 2, value: 1) if agreement_params['require_tel']
      Agreement.create!(profile_id: @profile.id, form_item_id: 3, value: 1) if agreement_params['require_posting']
      Agreement.create!(profile_id: @profile.id, form_item_id: 4, value: 1) if agreement_params['agree_ms']
      Agreement.create!(profile_id: @profile.id, form_item_id: 5, value: 1) if agreement_params['agree_ms_cndo2021']

      Agreement.create!(profile_id: @profile.id, form_item_id: 6, value: 1) if agreement_params['ibm_require_email_cndt2022']
      Agreement.create!(profile_id: @profile.id, form_item_id: 7, value: 1) if agreement_params['ibm_require_tel_cndt2022']
      Agreement.create!(profile_id: @profile.id, form_item_id: 8, value: 1) if agreement_params['redhat_require_email_cndt2022']
      Agreement.create!(profile_id: @profile.id, form_item_id: 9, value: 1) if agreement_params['redhat_require_tel_cndt2022']

      ProfileMailer.registered(@profile, @conference).deliver_later
      if @profile.public_profile.present?
        redirect_to("/#{event_name}/public_profiles/#{@profile.public_profile.id}/edit")
      else
        redirect_to("/#{event_name}/public_profiles/new")
      end
    else
      respond_to do |format|
        format.html { render(:new) }
        format.json { render(json: @profile.errors, status: :unprocessable_entity) }
      end
    end
  end

  def update
    postal_code = profile_params[:company_postal_code].gsub(/-/, '')
    tel = profile_params[:company_tel].gsub(/-/, '')
    respond_to do |format|
      if @profile.update(profile_params.merge(conference_id: @conference.id, company_postal_code: postal_code, company_tel: tel))
        format.html { redirect_to(edit_profile_path(id: @profile.id), notice: '登録情報の変更が完了しました') }
        format.json { render(:show, status: :ok, location: @profile) }
      else
        format.html { render(:edit, notice: '登録情報の変更時にエラーが発生しました') }
        format.json { render(json: @profile.errors, status: :unprocessable_entity) }
      end
    end
  end

  def destroy
    @profile.destroy
    reset_session
    redirect_to(logout_url.to_s)
  end

  def destroy_id
    @found_profile.destroy
    respond_to do |format|
      format.json { head(:no_content) }
    end
  end

  def set_role
    puts(params[:roles])
  end

  def calendar
    respond_to do |format|
      format.ics do
        code = params[:code]
        filename = Profile.find_by(calendar_unique_code: code).export_ics
        stat = File.stat(filename)
        send_file(filename, filename: "#{code}.ics", length: stat.size)
      end
    end
  end

  def profile_url
    case action_name
    when 'new'
      "/#{params[:event]}/profiles"
    when 'edit'
      "/#{params[:event]}/profiles/#{params[:id]}"
    end
  end

  def checkin
    ticket = Ticket.find_by(id: params[:ticket_id])
    if @profile.present? &&
       ticket.present? &&
       @profile.active_order.present? &&
       CheckIn.where(profile_id: @profile.id, order_id: @profile.active_order.id, ticket_id: ticket.id).empty?
      c = CheckIn.new
      c.profile_id = @profile.id
      c.order_id = @profile.active_order.id
      c.ticket_id = ticket.id
      c.save

      # TODO: This is a temporary solution. We should replace hardcoded values after CNDT2022.
      begin
        if ['dreamkast', 'dreamkast-staging'].include?(ENV['DREAMKAST_NAMESPACE'])
          checkin_point_event_id = '0bdce2ed486744c1205feca7070b31dd66b0649c'
          bonus_point_event_id = '21735f8eb9f786cc2f054c2df12606f8a659001a'
        else
          checkin_point_event_id = '438f2da574029a62ff2f24be87fee2cf583d130b'
          bonus_point_event_id = '62292c67bd1d3ff19ee7f4c001bc09a828b4f784'
        end
        api_client = DreamkastApiClient.new(@conference.abbr)
        api_client.add_point(checkin_point_event_id, @profile.id) # 会場チェックイン
        api_client.add_point(bonus_point_event_id, @profile.id) if @profile.created_at < Time.parse('2023-03-20') # 事前登録ボーナス
      rescue => e
        p(e)
      end
    elsif @profile.nil?
      redirect_to("/#{params[:event]}/registration")
    else
      redirect_to(dashboard_path)
    end
  end

  helper_method :profile_url

  private

  def find_profile
    @found_profile = Profile.find(parmas[:id])
    unless @found_profile
      format.json { render(json: 'Not found', status: :not_found) }
    end
  end

  def set_current_profile
    @profile = Profile.find_by(email: @current_user[:info][:email], conference_id: set_conference.id)
  end

  def profile_params
    params.require(:profile).permit(
      :sub,
      :email,
      :last_name,
      :first_name,
      :last_name_kana,
      :first_name_kana,
      :industry_id,
      :company_name_prefix_id,
      :company_name,
      :company_name_suffix_id,
      :company_email,
      :company_postal_code,
      :company_address_level1,
      :company_address_level2,
      :company_address_line1,
      :company_address_line2,
      :company_address_prefecture_id,
      :company_tel,
      :department,
      :position,
      :participation,
      :roles,
      :conference_id,
      :number_of_employee_id,
      :annual_sales_id,
      :company_fax,
      :occupation_id
    )
  end

  def agreement_params
    params.require(:profile).permit(
      :require_email,
      :require_tel,
      :require_posting,
      :agree_ms,
      :agree_ms_cndo2021,
      # for CNDT2022
      :ibm_require_email_cndt2022,
      :ibm_require_tel_cndt2022,
      :redhat_require_email_cndt2022,
      :redhat_require_tel_cndt2022
    )
  end
end
