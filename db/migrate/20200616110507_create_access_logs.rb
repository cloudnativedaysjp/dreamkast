class CreateAccessLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :access_logs do |t|
      t.string :name
      t.string :sub
      t.string :page
      t.string :ip

      t.timestamps
    end
  end
end
