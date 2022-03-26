# == Schema Information
#
# Table name: proposal_item_configs
#
#  id            :integer          not null, primary key
#  conference_id :integer          not null
#  type          :string(255)
#  item_number   :integer
#  label         :string(255)
#  item_name     :string(255)
#  params        :json
#  description   :text(65535)
#  key           :string(255)
#  value         :string(255)
#
# Indexes
#
#  index_proposal_item_configs_on_conference_id  (conference_id)
#

class ProposalItemConfig < ApplicationRecord
  belongs_to :conference
end
