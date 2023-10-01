class AddStreamingIdColumnsToMediaPackageTables < ActiveRecord::Migration[7.0]
  def up
    create_table :media_package_parameters, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_package_channel, null: false, foreign_key: true, type: :bigint

      t.string :name, null: true
      t.timestamps
    end unless ActiveRecord::Base.connection.table_exists?(:media_package_parameters)

    add_belongs_to :media_package_channels, :streaming, null: true, foreign_key: true, type: :string
    add_belongs_to :media_package_origin_endpoints, :streaming, null: true, foreign_key: true, type: :string

    remove_belongs_to :media_package_channels, :conference
    remove_belongs_to :media_package_channels, :track

    remove_belongs_to :media_package_origin_endpoints, :conference
  end

  def down
    add_belongs_to :media_package_origin_endpoints, :conference, null: false, foreign_key: true, type: :bigint

    add_belongs_to :media_package_channels, :track, null: false, foreign_key: true, type: :bigint
    add_belongs_to :media_package_channels, :conference, null: false, foreign_key: true, type: :bigint

    remove_belongs_to :media_package_channels, :streaming
    remove_belongs_to :media_package_origin_endpoints, :streaming

    drop_table :media_package_parameters
  end
end
