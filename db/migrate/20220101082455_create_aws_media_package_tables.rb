class CreateAwsMediaPackageTables < ActiveRecord::Migration[6.0]
  def change
    create_table :media_package_channels do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :track, null: false, foreign_key: true
      t.string :channel_id
    end

    create_table :media_package_origin_endpoints do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :media_package_channel, null: false, foreign_key: true
      t.string :endpoint_id
    end

    create_table :media_package_harvest_jobs do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :media_package_channel, null: false, foreign_key: true
      t.belongs_to :talk, null: false, foreign_key: true
      t.string :job_id
      t.datetime :start_time
      t.datetime :end_time
    end
  end
end
