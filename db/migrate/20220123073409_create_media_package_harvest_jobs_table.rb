class CreateMediaPackageHarvestJobsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :media_package_harvest_jobs do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :media_package_channel, null: false, foreign_key: true, type: :bigint
      t.belongs_to :talk, null: false, foreign_key: true, type: :bigint
      t.string :job_id
      t.string :status
      t.datetime :start_time
      t.datetime :end_time
    end
  end
end
