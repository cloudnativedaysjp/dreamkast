class Admin::RoomsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @rooms = @conference.rooms
  end

  def update
    errors = []
    @rooms = []
    respond_to do |format|
      ActiveRecord::Base.transaction do
        rooms_params.each do |id, room_param|
          room = Room.find(id)
          r = room.update!(room_param)
          errors << r unless r
          if room.track.present?
            room.track.talks.each do |talk|
              talk.update!(number_of_seats: room_param[:number_of_seats])
              errors << r unless r
            end
          end
          @rooms << room
        end
      end

      if errors.empty?
        format.html { redirect_to(admin_rooms_path, notice: '部屋の設定を更新しました') }
      else
        errors.each do |e|
          logger.error(e.message)
        end
        format.html { redirect_to(admin_rooms_path, notice: '部屋の設定を更新できませんでした') }
      end
    end
  end

  private

  def rooms_params
    params.permit(rooms: [:number_of_seats, :description])[:rooms]
  end
end
