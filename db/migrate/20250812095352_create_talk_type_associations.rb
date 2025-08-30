class CreateTalkTypeAssociations < ActiveRecord::Migration[8.0]
  def change
    create_table :talk_type_associations do |t|
      t.references :talk, null: false, foreign_key: true
      t.references :talk_type, null: false, foreign_key: true, type: :string

      t.timestamps

      t.index [:talk_id, :talk_type_id], unique: true, name: 'idx_talk_types_unique'
    end
  end
end