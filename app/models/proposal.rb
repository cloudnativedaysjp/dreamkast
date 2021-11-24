# == Schema Information
#
# Table name: proposals
#
#  id            :bigint           not null, primary key
#  status        :integer          default("registered"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer          not null
#  talk_id       :integer          not null
#
class Proposal < ApplicationRecord
  enum status: { registered: 0, accepted: 1, rejected: 2 }

  belongs_to :talk

  def speakers
    talk.speakers
  end
end
