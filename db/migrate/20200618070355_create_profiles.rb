class CreateProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :profiles do |t|
      t.string :sub
      t.string :email
      t.string :last_name
      t.string :first_name
      t.integer :industry_id
      t.string :occupation
      t.string :company_name
      t.string :company_email
      t.string :company_address
      t.string :company_tel
      t.string :department
      t.string :position

      t.timestamps
    end
  end
end
