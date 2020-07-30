class CreateSponsorAttachments < ActiveRecord::Migration[6.0]
  def change
    create_table :sponsor_attachments do |t|
      t.belongs_to :sponsor, null: false, foreign_key: true
      t.string :type
      t.string :url
      t.text :text
      t.string :link
      t.boolean :public
      t.string :file_data

      t.timestamps
    end
  end
end
