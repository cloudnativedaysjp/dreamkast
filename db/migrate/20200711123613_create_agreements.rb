class CreateAgreements < ActiveRecord::Migration[6.0]
  def change
    create_table :agreements do |t|
      t.integer :profile_id
      t.integer :form_item_id
      t.integer :value

      t.timestamps
    end
  end
end
