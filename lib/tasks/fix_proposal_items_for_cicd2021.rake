namespace :db do
  desc 'fix_proposal_items_for_cicd2021'
  task fix_proposal_items_for_cicd2021: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::DEBUG

    ActiveRecord::Base.transaction do
      begin
        Talk.where(conference_id: 3).each do |talk|
          assumed_visitor = talk.proposal_items.find_by(label: 'assumed_visitor').params
          talk.proposal_items.find_by(label: 'assumed_visitor').update!(params: assumed_visitor.select { |i| !i.to_i.zero? })

          execution_phase = talk.proposal_items.find_by(label: 'execution_phase').params
          talk.proposal_items.find_by(label: 'execution_phase').update!(params: execution_phase.select { |i| !i.to_i.zero? })
        end
      rescue => e
        puts(e)
      end
    end
  end
end
