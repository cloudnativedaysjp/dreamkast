namespace :db do
  desc 'migrate_talks_to_proposal_items'
  task migrate_talks_to_proposal_items: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    ActiveRecord::Base.transaction do
      begin
        Talk.where(conference_id: 3).each do |talk|
          ProposalItem.new(conference_id: 3, talk_id: talk.id, label: 'assumed_visitor', params: talk.expected_participants).save!
          ProposalItem.new(conference_id: 3, talk_id: talk.id, label: 'execution_phase', params: talk.execution_phases).save!
        end
      rescue => e
        puts(e)
      end
    end
  end
end
