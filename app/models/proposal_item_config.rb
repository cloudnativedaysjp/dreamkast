# == Schema Information
#
# Table name: proposal_item_configs
#
#  id            :bigint           not null, primary key
#  description   :text(65535)
#  item_name     :string(255)
#  item_number   :integer
#  key           :string(255)
#  label         :string(255)
#  params        :json
#  type          :string(255)
#  value         :string(255)
#  conference_id :bigint           not null
#
# Indexes
#
#  index_proposal_item_configs_on_conference_id  (conference_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#

class ProposalItemConfig < ApplicationRecord
  belongs_to :conference
end
