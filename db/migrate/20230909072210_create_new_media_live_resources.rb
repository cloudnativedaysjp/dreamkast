class CreateNewMediaLiveResources < ActiveRecord::Migration[7.0]
  def up
    create_table :media_live_input_security_groups, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string

      t.string :input_security_group_id, null: true
      t.timestamps
    end unless ActiveRecord::Base.connection.table_exists?(:media_live_input_security_groups)

    create_table :media_live_inputs, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_live_input_security_group, null: false, foreign_key: true, type: :string

      t.string :input_id, null: true
      t.timestamps
    end unless ActiveRecord::Base.connection.table_exists?(:media_live_inputs)

    create_table :media_live_channels, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_live_input, null: false, foreign_key: true, type: :string

      t.string :channel_id, null: true
      t.timestamps
    end unless ActiveRecord::Base.connection.table_exists?(:media_live_channels)
  end

  def down
    drop_table :media_live_channels
    drop_table :media_live_inputs
    drop_table :media_live_input_security_groups
  end
end
