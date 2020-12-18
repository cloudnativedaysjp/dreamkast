class AddConferenceId < ActiveRecord::Migration[6.0]
  def change
    add_column :industries, :conference_id, :integer
    add_column :profiles, :conference_id, :integer
    add_column :speakers, :conference_id, :integer
    add_column :talk_categories, :conference_id, :integer
    add_column :talk_difficulties, :conference_id, :integer
  end
end
