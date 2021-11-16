# == Schema Information
#
# Table name: conference_days
#
#  id            :bigint           not null, primary key
#  date          :date
#  end_time      :time
#  internal      :boolean          default(FALSE), not null
#  start_time    :time
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :bigint
#
# Indexes
#
#  index_conference_days_on_conference_id  (conference_id)
#
require "rails_helper"

RSpec.describe(ConferenceDay, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
