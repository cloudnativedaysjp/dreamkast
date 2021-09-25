class AddColumnsToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :company_address_prefecture_id, :string
  end
end
