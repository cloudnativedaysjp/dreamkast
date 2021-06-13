class ProposalsSpeaker < ApplicationRecord
  belongs_to :proposal, optional: true
  belongs_to :speaker, optional: true
end
