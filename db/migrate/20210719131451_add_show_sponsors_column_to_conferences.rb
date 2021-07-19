class AddShowSponsorsColumnToConferences < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :show_sponsors, :boolean, :default => false
  end
end
