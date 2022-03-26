# == Schema Information
#
# Table name: proposals
#
#  id            :integer          not null, primary key
#  talk_id       :integer          not null
#  conference_id :integer          not null
#  status        :integer          default("0"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Proposal < ApplicationRecord
  enum status: { registered: 0, accepted: 1, rejected: 2 }

  belongs_to :talk

  def speakers
    talk.speakers
  end
end
