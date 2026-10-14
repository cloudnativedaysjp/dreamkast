class AddIndexProfilesOnConferenceIdAndParticipation < ActiveRecord::Migration[8.1]
  def change
    add_index :profiles, [:conference_id, :participation],
              name: 'index_profiles_on_conference_id_and_participation'
  end
end
