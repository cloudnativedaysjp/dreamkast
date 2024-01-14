# == Schema Information
#
# Table name: talks
#
#  id                    :bigint           not null, primary key
#  abstract              :text(65535)
#  acquired_seats        :integer          default(0), not null
#  document_url          :string(255)
#  end_offset            :integer          default(0), not null
#  end_time              :time
#  execution_phases      :json
#  expected_participants :json
#  movie_url             :string(255)
#  number_of_seats       :integer          default(0), not null
#  show_on_timetable     :boolean
#  start_offset          :integer          default(0), not null
#  start_time            :time
#  title                 :string(255)
#  type                  :string(255)      not null
#  video_published       :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  conference_day_id     :integer
#  conference_id         :integer
#  sponsor_id            :integer
#  talk_category_id      :bigint
#  talk_difficulty_id    :bigint
#  talk_time_id          :integer
#  track_id              :integer
#
# Indexes
#
#  index_talks_on_conference_id       (conference_id)
#  index_talks_on_talk_category_id    (talk_category_id)
#  index_talks_on_talk_difficulty_id  (talk_difficulty_id)
#  index_talks_on_track_id            (track_id)
#
class SponsorSession < Talk
end
