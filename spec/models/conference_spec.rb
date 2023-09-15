# == Schema Information
#
# Table name: conferences
#
#  id                         :bigint           not null, primary key
#  abbr                       :string(255)
#  about                      :text(65535)
#  attendee_entry             :integer          default("attendee_entry_disabled")
#  brief                      :string(255)
#  cfp_result_visible         :boolean          default(FALSE)
#  coc                        :text(65535)
#  committee_name             :string(255)      default("CloudNative Days Committee"), not null
#  conference_status          :string(255)      default("registered")
#  copyright                  :string(255)
#  name                       :string(255)
#  privacy_policy             :text(65535)
#  privacy_policy_for_speaker :text(65535)
#  rehearsal_mode             :boolean          default(FALSE), not null
#  show_sponsors              :boolean          default(FALSE)
#  show_timetable             :integer          default("show_timetable_disabled")
#  speaker_entry              :integer          default("speaker_entry_disabled")
#  theme                      :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_conferences_on_abbr                        (abbr)
#  index_conferences_on_abbr_and_conference_status  (abbr,conference_status)
#

require 'rails_helper'

RSpec.describe(Conference, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
