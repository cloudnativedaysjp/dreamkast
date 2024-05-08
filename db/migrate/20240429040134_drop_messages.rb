class DropMessages < ActiveRecord::Migration[7.0]
  def change
    drop_table "messages" do |t|
      t.string "content"
      t.string "text"
      t.timestamps
    end
  end
end
