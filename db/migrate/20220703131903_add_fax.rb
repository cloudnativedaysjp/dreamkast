class AddFax < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :company_fax, :string, null: true
  end
end
