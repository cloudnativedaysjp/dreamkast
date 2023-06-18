class CreatePublicProfilesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :public_profiles do |t|
      t.belongs_to :profile, null: false, foreign_key: true, type: :bigint
      t.string  :nickname,    type: :string,  default: ""
      t.string  :twitter_id,  type: :string,  default: ""
      t.string  :github_id,   type: :string,  default: ""
      t.string  :avatar_data, type: :text
      t.boolean :is_public,   type: :boolean, default: false
    end
  end
end
