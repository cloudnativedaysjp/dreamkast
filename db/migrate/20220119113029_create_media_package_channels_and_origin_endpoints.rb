class CreateMediaPackageChannelsAndOriginEndpoints < ActiveRecord::Migration[6.0]
  def change
    create_table :media_package_channels do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.string :channel_id, null: true
      t.index :channel_id, unique: true
    end

    create_table :media_package_origin_endpoints do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :media_package_channel, null: false, foreign_key: true, type: :bigint
      t.string :endpoint_id
    end
  end
end
