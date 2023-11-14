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

  def self.count_proposal_items
    select('proposal_items.label, proposal_item_configs.params as value_name, proposal_items.conference_id, COUNT(*) as count')
      .joins('LEFT JOIN proposal_item_configs ON proposal_item_configs.id = proposal_items.params')
      .where(label: ['presentation_method', 'assumed_visitor', 'execution_phase', 'whether_it_can_be_published', 'session_time', 'language'])
      .group('proposal_items.label, proposal_item_configs.params,proposal_items.conference_id')
  end
end
