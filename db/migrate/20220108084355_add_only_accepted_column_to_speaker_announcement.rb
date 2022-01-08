class AddOnlyAcceptedColumnToSpeakerAnnouncement < ActiveRecord::Migration[6.0]
  def change
    add_column :speaker_announcements, :only_accepted, :boolean, default: false
    add_column :speaker_announcements, :to_all, :boolean, default: false
  end
end
