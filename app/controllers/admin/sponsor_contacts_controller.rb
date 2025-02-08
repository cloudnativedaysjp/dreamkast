class Admin::SponsorContactsController < ApplicationController
  include SecuredAdmin

  def destroy
    @sponsor_contact = SponsorContact.find(params[:id])

    if @sponsor_contact.destroy
      flash.now.notice = "スポンサー担当者 #{@sponsor_contact.email} を削除しました"
    else
      flash.now.alert = "スポンサー担当者 #{@sponsor_contact.email} の削除に失敗しました"
    end
  end

  helper_method :turbo_stream_flash

  private

  def turbo_stream_flash
    turbo_stream.append('flashes', partial: 'flash')
  end
end
