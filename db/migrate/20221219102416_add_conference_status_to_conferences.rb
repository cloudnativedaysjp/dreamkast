class AddConferenceStatusToConferences < ActiveRecord::Migration[7.0]
  def up
    add_column :conferences, :conference_status, :string, default: ""
    Conference.all.each do |conference|
      case conference.status
      when Conference::STATUS_REGISTERED
        conference.update!(conference_status: Conference::STATUS_REGISTERED)
      when Conference::STATUS_OPENED
        conference.update!(conference_status: Conference::STATUS_OPENED)
      when Conference::STATUS_CLOSED
        conference.update!(conference_status: Conference::STATUS_CLOSED)
      when Conference::STATUS_ARCHIVED
        conference.update!(conference_status: Conference::STATUS_ARCHIVED)
      end
    end
  end

  def down
    remove_column :conferences, :conference_status
  end
end
