# == Schema Information
#
# Table name: conferences
#
#  id                         :bigint           not null, primary key
#  abbr                       :string(255)
#  about                      :text(65535)
#  attendee_entry             :integer
#  brief                      :string(255)
#  cfp_result_visible         :boolean          default(FALSE)
#  coc                        :text(65535)
#  copyright                  :string(255)
#  name                       :string(255)
#  privacy_policy             :text(65535)
#  privacy_policy_for_speaker :text(65535)
#  show_sponsors              :boolean          default(FALSE)
#  show_timetable             :integer
#  speaker_entry              :integer
#  status                     :integer          default("registered"), not null
#  theme                      :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_conferences_on_status  (status)
#
require 'rails_helper'

RSpec.describe(Conference, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
