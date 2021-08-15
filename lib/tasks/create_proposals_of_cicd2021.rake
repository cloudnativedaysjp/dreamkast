namespace :db do
  desc "create_proposals_of_cicd2021"
  task create_proposals_of_cicd2021: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    ActiveRecord::Base.transaction do
      begin
        conference = Conference.find_by(abbr: 'cicd2021')
        conference.talks.each do |talk|
          if talk.proposal.nil?
            proposal = Proposal.new(conference_id: conference.id, talk_id: talk.id, status: 0)
            proposal.save!
          end
        end
      rescue => e
        puts e
      end
    end
  end
end
