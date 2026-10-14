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
end
