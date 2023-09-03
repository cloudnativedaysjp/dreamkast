class CreateMediaPackageV2ChannelTable < ActiveRecord::Migration[7.0]
  def change

    create_table :media_package_v2_channel_groups do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.string :name, null: true
      t.index :name, unique: true
    end

    create_table :media_package_v2_channels do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.bigint :media_package_v2_channel_group_id, null: false

      t.string :name, null: true
      t.index :name, unique: true
    end
    add_index :media_package_v2_channels, :media_package_v2_channel_group_id, name: 'index_channels_on_channel_group_id'

    create_table :media_package_v2_origin_endpoints do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.bigint :media_package_v2_channel_id, null: false
      t.string :name, null: true
      t.index :name, unique: true
    end

    add_index :media_package_v2_origin_endpoints, :media_package_v2_channel_id, name: 'index_origin_endpoints_on_channel_id'
  end
end
