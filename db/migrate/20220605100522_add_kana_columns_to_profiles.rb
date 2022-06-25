class AddKanaColumnsToProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :first_name_kana, :string
    add_column :profiles, :last_name_kana, :string
  end
end
