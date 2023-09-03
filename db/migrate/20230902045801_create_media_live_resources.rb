class CreateMediaLiveResources < ActiveRecord::Migration[7.0]
  def change
    create_table :media_live_input_security_groups do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.string :input_security_group_id, null: true

      t.timestamps
    end

    create_table :media_live_inputs do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :media_live_input_security_group, null: false, foreign_key: true, type: :bigint
      t.string :input_id, null: true

      t.timestamps
    end

    create_table :media_live_channels do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :media_live_input, null: false, foreign_key: true, type: :bigint
      t.string :channel_id, null: true

      t.timestamps
    end

    create_table :media_package_parameters do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.belongs_to :media_package_channel, null: false, foreign_key: true, type: :bigint
      t.string :name, null: true

      t.timestamps
    end
  end
end
