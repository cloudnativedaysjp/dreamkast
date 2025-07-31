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
    ProposalItem.joins(:talk)
                .select(:talks.id(AS(talk_id)), :label, :params, :conference_id)
  end
end
