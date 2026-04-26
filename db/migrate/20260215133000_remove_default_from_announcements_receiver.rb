class RemoveDefaultFromAnnouncementsReceiver < ActiveRecord::Migration[6.0]
  def change
    change_column_default :announcements, :receiver, from: 0, to: nil
  end
end
