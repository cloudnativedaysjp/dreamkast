class CreateMultipartUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :multipart_uploads do |t|
      t.references :user, null: false, foreign_key: true
      t.string :upload_id, null: false
      t.string :key, null: false
      t.bigint :byte_size, null: false
      t.integer :part_size, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :multipart_uploads, :upload_id, unique: true
    add_index :multipart_uploads, :expires_at
  end
end
