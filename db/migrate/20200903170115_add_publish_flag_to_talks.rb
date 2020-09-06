class AddPublishFlagToTalks < ActiveRecord::Migration[6.0]
  def change
    add_column :talks, :video_published, :boolean, null: false, default: false
    add_column :talks, :document_url, :string
  end
end
