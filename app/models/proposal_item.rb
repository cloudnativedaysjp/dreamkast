# == Schema Information
#
# Table name: proposal_items
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  talk_id       :integer          not null
#  label         :string(255)
#  params        :json
#
# Indexes
#
#  index_proposal_items_on_conference_id  (conference_id)
#  index_proposal_items_on_talk_id        (talk_id)
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
end
