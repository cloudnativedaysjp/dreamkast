# == Schema Information
#
# Table name: conference_days
#
#  id            :integer          not null, primary key
#  date          :date
#  start_time    :time
#  end_time      :time
#  conference_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  internal      :boolean          default("0"), not null
#
# Indexes
#
#  index_conference_days_on_conference_id  (conference_id)
#

require 'rails_helper'

RSpec.describe(ConferenceDay, type: :model) do
  pending "add some examples to (or delete) #{__FILE__}"
end
