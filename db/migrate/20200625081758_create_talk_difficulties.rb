class CreateTalkDifficulties < ActiveRecord::Migration[6.0]
  def change
    create_table :talk_difficulties do |t|
      t.string :name

      t.timestamps
    end
  end
end
