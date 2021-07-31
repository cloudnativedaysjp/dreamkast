class ProposalItem < ApplicationRecord
  belongs_to :conference
  belongs_to :talk
end
