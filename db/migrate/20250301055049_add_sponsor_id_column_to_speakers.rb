class AddSponsorIdColumnToSpeakers < ActiveRecord::Migration[7.0]
  def change
    add_reference :speakers, :sponsor, null: true, index: false
  end
end
