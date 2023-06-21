namespace :db do
  desc 'modify_session_time_for_keynote_cndf2023'
  task modify_session_time_for_keynote_cndf2023: :environment do
    ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    keynotes = [1907, 1910, 1561, 1911, 1913]

    ActiveRecord::Base.transaction do
      begin
        keynotes.each do |keynote|
          talk = Talk.find(keynote)
          item = talk.proposal_items.find_by(label: 'session_time')
          item.params = '119'  # 40min = 116, 20min = 119

          if ENV['DRY_RUN'] == 'false'
            item.save!
          else
            puts("[Dry Run] Set talk_time #{talk.title} to #{item.proposal_item_configs[0].value}")
          end
        rescue => e
          puts(e)
        end
      end
    end
  end
end
