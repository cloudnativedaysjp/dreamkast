class AddColumnsToConferences < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :privacy_policy_for_speaker, :text
  end
end
