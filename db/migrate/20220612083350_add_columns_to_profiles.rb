class AddColumnsToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :company_name_prefix_id, :string
    add_column :profiles, :company_name_suffix_id, :string
    add_column :profiles, :company_postal_code, :string
    add_column :profiles, :company_address_level1_id, :integer
    add_column :profiles, :company_address_level2, :string
    add_column :profiles, :company_address_line1, :string
    add_column :profiles, :company_address_line2, :string

  end
end
