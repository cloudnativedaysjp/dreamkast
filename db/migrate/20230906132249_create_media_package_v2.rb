class CreateMediaPackageV2 < ActiveRecord::Migration[7.0]
  def up
    create_table :media_package_v2_channel_groups, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.string :name, null: true
      t.index :name, unique: true
    end unless ActiveRecord::Base.connection.table_exists?(:media_package_v2_channel_groups)

    create_table :media_package_v2_channels, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_package_v2_channel_group, null: true, type: :string, index: {name: 'index_channels_on_channel_group_id'}

      t.string :name, null: true
      t.index :name, unique: true
    end unless ActiveRecord::Base.connection.table_exists?(:media_package_v2_channels)

    create_table :media_package_v2_origin_endpoints, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_package_v2_channel, null: true, type: :string, index: {name: 'index_origin_endpoints_on_channel_id'}
      t.string :name, null: true
      t.index :name, unique: true
    end unless ActiveRecord::Base.connection.table_exists?(:media_package_v2_origin_endpoints)
  end

  def down
    drop_table :media_package_v2_origin_endpoints
    drop_table :media_package_v2_channels
    drop_table :media_package_v2_channel_groups
  end
end
