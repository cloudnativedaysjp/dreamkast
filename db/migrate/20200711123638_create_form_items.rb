class CreateFormItems < ActiveRecord::Migration[6.0]
  def change
    create_table :form_items do |t|
      t.integer :conference_id
      t.string :name

      t.timestamps
    end
  end
end
