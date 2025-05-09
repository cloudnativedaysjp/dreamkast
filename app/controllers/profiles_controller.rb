class ProfilesController < ApplicationController
  include Secured

  before_action :set_conference
  before_action :set_current_profile, only: [:edit, :update, :destroy, :checkin, :entry_sheet, :view_qr]
  skip_before_action :logged_in_using_omniauth?, only: [:new]
  before_action :find_profile, only: [:destroy_id, :set_role]
  before_action :is_admin?, :find_profile, only: [:destroy_id, :set_role]
  before_action :set_speaker, only: [:entry_sheet]

  def new
    @profile = Profile.new
    @conference = Conference.find_by(abbr: params[:event])

    # FormItemの数だけform_valuesを初期化
    FormItem.where(conference_id: @conference.id).each do |form_item|
      @profile.form_values.build(form_item_id: form_item.id)
    end

    if current_user && Profile.find_by(conference_id: @conference.id, email: current_user[:info][:email])
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
    @profile.sub = current_user[:extra][:raw_info][:sub]
    @profile.email = current_user[:info][:email]

    if @profile.save
      # フォーム項目の値を保存
      if params[:form_item].present?
        params[:form_item].each do |attr, value|
          form_item = FormItem.find_by(attr:, conference_id: @conference.id)
          if form_item
            FormValue.create!(profile_id: @profile.id, form_item_id: form_item.id, value:)
          end
        end
      end

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
        # フォーム項目の値を更新
        if params[:form_item].present?
          params[:form_item].each do |attr, value|
            form_item = FormItem.find_by(attr:, conference_id: @conference.id)
            if form_item
              # 既存のフォーム値を探すか、新しく作成
              form_value = @profile.form_values.find_or_initialize_by(form_item_id: form_item.id)
              form_value.value = value
              form_value.save!
            end
          end
        end

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
    redirect_to(logout_url)
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

  def view_qr
  end

  def entry_sheet
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
    @profile = Profile.find_by(email: current_user[:info][:email], conference_id: set_conference.id)
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
      :occupation_id,
      form_items_attributes: form_items_params
    )
  end

  def form_items_params
    FormItem.where(conference_id: @conference.id).map { |item| item.attr.to_sym }
  end
end
