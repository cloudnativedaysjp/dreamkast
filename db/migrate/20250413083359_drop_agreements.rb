class DropAgreements < ActiveRecord::Migration[7.0]
  def up
    # データ移行が必要な場合はここで行う
    # 例: Agreement.find_each do |agreement|
    #   FormValue.create!(
    #     profile_id: agreement.profile_id,
    #     form_item_id: agreement.form_item_id,
    #     value: agreement.value.to_s
    #   )
    # end

    drop_table :agreements
  end

  def down
    create_table :agreements do |t|
      t.integer :profile_id
      t.integer :form_item_id
      t.integer :value

      t.timestamps
    end
  end
end
