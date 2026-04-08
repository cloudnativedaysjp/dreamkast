class CreateFormValues < ActiveRecord::Migration[7.0]
  def change
    create_table :form_values do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :form_item, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
