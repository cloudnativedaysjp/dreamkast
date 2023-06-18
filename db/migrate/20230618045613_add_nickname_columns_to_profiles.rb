class AddNicknameColumnsToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :nickname, :string, default: ""
    add_column :profiles, :twitter_id, :string, default: ""
    add_column :profiles, :github_id, :string, default: ""
    add_column :profiles, :avatar_data, :string, default: ""
    add_column :profiles, :is_public, :boolean, default: false
  end
end
