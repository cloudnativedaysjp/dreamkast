class CreateMediaPackageV2ChannelTable < ActiveRecord::Migration[7.0]
  def change
    create_table :streamings, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.string :status, null: false

      t.timestamps
      t.index  [:conference_id, :track_id], unique: true
    end

    create_table :media_package_v2_channel_groups, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.string :name, null: true
      t.index :name, unique: true
    end

    create_table :media_package_v2_channels, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_package_v2_channel_group, null: true, type: :string, index: {name: 'index_channels_on_channel_group_id'}

      t.string :name, null: true
      t.index :name, unique: true
    end

    create_table :media_package_v2_origin_endpoints, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_package_v2_channel, null: true, type: :string, index: {name: 'index_origin_endpoints_on_channel_id'}
      t.string :name, null: true
      t.index :name, unique: true
    end

    create_table :media_live_input_security_groups, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string

      t.string :input_security_group_id, null: true
      t.timestamps
    end

    create_table :media_live_inputs, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_live_input_security_group, null: false, foreign_key: true, type: :string

      t.string :input_id, null: true
      t.timestamps
    end

    create_table :media_live_channels, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_live_input, null: false, foreign_key: true, type: :string

      t.string :channel_id, null: true
      t.timestamps
    end

    create_table :media_package_parameters, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_package_channel, null: false, foreign_key: true, type: :bigint

      t.string :name, null: true
      t.timestamps
    end

    add_column :media_package_channels, :streaming_id, :string, null: true
    add_column :media_package_origin_endpoints, :streaming_id, :string, null: true
  end
end
