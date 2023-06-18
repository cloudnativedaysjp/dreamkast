class PublicProfilesController < ApplicationController
  include Secured
  before_action :set_conference

  def new
    @public_profile = PublicProfile.new(profile_id: @profile.id)
  end

  def edit
    @public_profile = PublicProfile.find(params[:id])
  end

  def create
    @public_profile = PublicProfile.new(public_profile_params.merge(profile_id: @profile.id))

    if @public_profile.save
      redirect_to("/#{event_name}/timetables")
    else
      respond_to do |format|
        format.html { render(:new, notice: 'プロフィールの登録時にエラーが発生しました') }
      end
    end
  end

  def update
    @public_profile = PublicProfile.find(params[:id])

    respond_to do |format|
      if @public_profile.update(public_profile_params)
        format.html { redirect_to(edit_public_profile_path(id: @public_profile.id), notice: 'プロフィールのの変更が完了しました') }
        format.json { render(:show, status: :ok, location: @public_profile) }
      else
        format.html { render(:edit, notice: 'プロフィールの変更時にエラーが発生しました') }
      end
    end
  end

  def destroy
    @public_profile.destroy
  end

  helper_method :public_profile_path

  def public_profile_path
    case action_name
    when 'new'
      "/#{params[:event]}/public_profiles"
    when 'edit'
      "/#{params[:event]}/public_profiles/#{params[:id]}"
    end
  end

  def public_profile_params
    params.require(:public_profile).permit(
      :nickname,
      :twitter_id,
      :github_id,
      :is_public,
      :avatar
    )
  end
end
