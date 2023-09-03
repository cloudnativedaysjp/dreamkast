class CreateStreamingAwsResources < ActiveRecord::Migration[7.0]
  def change
    create_table :streaming_aws_resources, id: :string do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.belongs_to :track, null: false, foreign_key: true, type: :bigint
      t.string :status, null: false

      t.timestamps
      t.index  [:conference_id, :track_id], unique: true
    end
  end
end
