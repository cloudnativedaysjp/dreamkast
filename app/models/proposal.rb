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
  STATUS_MESSAGE = {
    'registered' => 'エントリー済み',
    'accepted' => '採択',
    'rejected' => '不採択'
  }.freeze

  belongs_to :talk

  def speakers
    talk.speakers
  end

  def status_message
    return STATUS_MESSAGE['registered'] unless talk.conference.cfp_result_visible
    STATUS_MESSAGE[status]
  end
end
