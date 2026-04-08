class AddSubConferenceTypeToTalkCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :talk_categories, :sub_conference_type, :string
    add_index :talk_categories, [:conference_id, :sub_conference_type]
  end
end
