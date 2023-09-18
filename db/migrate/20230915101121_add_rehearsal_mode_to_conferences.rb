class AddRehearsalModeToConferences < ActiveRecord::Migration[7.0]
  def up
    add_column :conferences, :rehearsal_mode, :boolean, default: false, null: false
    Conference.all.each do |conference|
      conference.update!(rehearsal_mode: false)
    end
  end

  def down
    remove_column :conferences, :rehearsal_mode
  end
end
