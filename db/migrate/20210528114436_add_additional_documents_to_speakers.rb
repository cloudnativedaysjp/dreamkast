class AddAdditionalDocumentsToSpeakers < ActiveRecord::Migration[6.0]
  def change
    add_column :speakers, :additional_documents, :text
  end
end
