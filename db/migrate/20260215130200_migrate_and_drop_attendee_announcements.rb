class MigrateAndDropAttendeeAnnouncements < ActiveRecord::Migration[6.0]
  class AttendeeAnnouncement < ActiveRecord::Base
    self.table_name = 'attendee_announcements'
  end

  class AttendeeAnnouncementMiddle < ActiveRecord::Base
    self.table_name = 'attendee_announcement_middles'
  end

  class Announcement < ActiveRecord::Base
    self.table_name = 'announcements'
  end

  class AnnouncementMiddle < ActiveRecord::Base
    self.table_name = 'announcement_middles'
  end

  def up
    return unless table_exists?(:attendee_announcements)

    id_map = {}

    AttendeeAnnouncement.find_each do |attendee|
      announcement = Announcement.create!(
        conference_id: attendee.conference_id,
        publish_time: attendee.publish_time,
        body: attendee.body,
        publish: attendee.publish,
        receiver: attendee.receiver || 0,
        created_at: attendee.created_at,
        updated_at: attendee.updated_at
      )
      id_map[attendee.id] = announcement.id
    end

    if table_exists?(:attendee_announcement_middles)
      AttendeeAnnouncementMiddle.find_each do |middle|
        announcement_id = id_map[middle.attendee_announcement_id]
        next if announcement_id.nil?

        AnnouncementMiddle.create!(
          announcement_id: announcement_id,
          profile_id: middle.profile_id,
          created_at: middle.created_at,
          updated_at: middle.updated_at
        )
      end
    end

    drop_table :attendee_announcement_middles if table_exists?(:attendee_announcement_middles)
    drop_table :attendee_announcements if table_exists?(:attendee_announcements)
  end

  def down
    return if table_exists?(:attendee_announcements)

    create_table :attendee_announcements do |t|
      t.belongs_to :conference, null: false, foreign_key: true, type: :bigint
      t.datetime :publish_time, null: false
      t.text :body, null: false
      t.boolean :publish, default: false, null: false
      t.integer :receiver, null: false, default: 0

      t.timestamps
    end

    create_table :attendee_announcement_middles do |t|
      t.references :profile, null: false, foreign_key: true, type: :bigint
      t.references :attendee_announcement, null: false, foreign_key: true, type: :bigint
      t.timestamps
    end
  end
end
