# == Schema Information
#
# Table name: proposal_items
#
#  id            :bigint           not null, primary key
#  label         :string(255)
#  params        :json
#  conference_id :bigint           not null
#  talk_id       :bigint           not null
#
# Indexes
#
#  index_proposal_items_on_conference_id  (conference_id)
#  index_proposal_items_on_talk_id        (talk_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class ProposalItem < ApplicationRecord
  belongs_to :conference
  belongs_to :talk
end
