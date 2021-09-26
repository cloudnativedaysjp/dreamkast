class AddShowOnTeamsPageColumnsToAdminProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :admin_profiles, :show_on_team_page, :boolean
  end
end
