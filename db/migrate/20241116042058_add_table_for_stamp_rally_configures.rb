class AddTableForStampRallyConfigures < ActiveRecord::Migration[7.0]
  def change
    create_table :stamp_rally_configures, id: false do |t|
      t.string :id, limit: 26, primary_key: true
      t.references :conference, null: false, foreign_key: true
      t.numeric :finish_threshold, null: false
    end
  end
end
