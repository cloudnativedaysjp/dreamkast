class AddTypeColumnToTalks < ActiveRecord::Migration[7.0]
  def up
    add_column :talks, :type, :string, after: :id

    Talk.where('sponsor_id IS NULL').update_all(type: 'SponsorSession')
    Talk.where('abstract = "intermission"').update_all(type: 'Intermission')
    Talk.where('sponsor_id IS NULL').where('abstract != "intermission"').update_all(type: 'Session')

    change_column_null :talks, :type, false
  end

  def down
    remove_column :talks, :type
  end
end
