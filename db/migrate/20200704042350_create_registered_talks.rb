class CreateRegisteredTalks < ActiveRecord::Migration[6.0]
  def change
    create_table :registered_talks do |t|
      t.integer :profile_id
      t.integer :talk_id

      t.timestamps
    end
  end
end
