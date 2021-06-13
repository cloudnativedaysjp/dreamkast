class CreateProposals < ActiveRecord::Migration[6.0]
  def change
    create_table :proposals do |t|
      t.integer :talk_id, null: false, foreign_key: true
      t.integer :conference_id, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    create_table :proposals_speakers do |t|
      t.integer :proposal_id
      t.integer :speaker_id

      t.timestamps
    end

    add_column :conferences, :cfp_result_visible, :boolean, default: false
  end
end
