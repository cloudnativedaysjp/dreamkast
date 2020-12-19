class AddColumnsToConference < ActiveRecord::Migration[6.0]
  def change
    add_column :conferences, :theme, :text
    add_column :conferences, :about, :text
    add_column :conferences, :privacy_policy, :text
    add_column :conferences, :coc, :text
    add_column :conferences, :copyright, :string
  end
end
