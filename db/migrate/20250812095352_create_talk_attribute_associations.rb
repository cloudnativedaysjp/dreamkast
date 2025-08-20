class CreateTalkAttributeAssociations < ActiveRecord::Migration[8.0]
  def change
    create_table :talk_attribute_associations do |t|
      t.references :talk, null: false, foreign_key: true
      t.references :talk_attribute, null: false, foreign_key: true
      
      t.timestamps
      
      t.index [:talk_id, :talk_attribute_id], unique: true, name: 'idx_talk_attrs_unique'
    end
  end
end
