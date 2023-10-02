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

  def proposal_item_configs
    return [] unless params

    case params
    when String
      [ProposalItemConfig.find(params.to_i)]
    when Array
      params.map { |param| ProposalItemConfig.find(param.to_i) }
    end
  end

  def self.select_proposal_items
    select('talks.id AS talk_id, proposal_items.label, proposal_items.params, proposal_items.conference_id')
      .from('proposal_items')
      .left_joins(:talk)
      .where(label: ['presentation_method', 'assumed_visitor', 'execution_phase', 'whether_it_can_be_published', 'session_time', 'language'])
  end
end
