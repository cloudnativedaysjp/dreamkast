# == Schema Information
#
# Table name: conferences
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  abbr                       :string(255)
#  status                     :integer          default("0"), not null
#  theme                      :text(65535)
#  about                      :text(65535)
#  privacy_policy             :text(65535)
#  coc                        :text(65535)
#  committee_name             :string(255)      default("CloudNative Days Committee"), not null
#  copyright                  :string(255)
#  privacy_policy_for_speaker :text(65535)
#  speaker_entry              :integer
#  attendee_entry             :integer
#  show_timetable             :integer
#  cfp_result_visible         :boolean          default("0")
#  show_sponsors              :boolean          default("0")
#  brief                      :string(255)
#
# Indexes
#
#  index_conferences_on_status  (status)
#

require 'rails_helper'

RSpec.describe(Conference, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
