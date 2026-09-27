class CreateMediaPackageV2HarvestJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :media_package_v2_archive_origin_endpoints, id: :string do |t|
      t.belongs_to :streaming, null: false, foreign_key: true, type: :string
      t.belongs_to :media_package_v2_channel, null: true, type: :string, index: { name: 'index_archive_origin_endpoints_on_channel_id' }
      t.string :name, null: true
      t.index :name, unique: true
    end

    create_table :media_package_v2_harvest_jobs do |t|
      t.belongs_to :conference, null: false, foreign_key: true
      t.belongs_to :talk, null: false, foreign_key: true
      # 配信リソース削除後も記録を残すため、エンドポイントへの参照は NULL を許容する
      t.belongs_to :media_package_v2_archive_origin_endpoint, null: true, type: :string, index: { name: 'index_v2_harvest_jobs_on_archive_origin_endpoint_id' }
      t.string :harvest_job_name
      t.string :status
      t.text :error_message
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :bucket_name
      t.string :destination_path
      t.timestamps
    end
  end
end
