class CreateTalkSessionAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :talk_session_attributes do |t|
      t.references :talk, null: false, foreign_key: true
      t.references :session_attribute, null: false, foreign_key: true
      
      t.timestamps
      
      t.index [:talk_id, :session_attribute_id], unique: true, name: 'idx_talk_session_attrs_unique'
    end
  end
end
