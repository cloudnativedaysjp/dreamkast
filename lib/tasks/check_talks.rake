require 'slack/incoming/webhooks'

namespace :util do
  desc 'check_talks'
  task check_talks: :environment do
    # ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG

    puts 'Checking talks...'

    Talk.all.each do |talk|
      if talk.sponsor_session? && !talk.session_type_names.include?('SponsorSession')
        puts("#{talk.id} doesn't include 'SponsorSession': #{talk.session_type_names}")
      end

      if talk.talk_category&.name == 'Keynote' && !talk.session_type_names.include?('KeynoteSession')
        puts("#{talk.id} doesn't include 'KeynoteSession': #{talk.session_type_names}")
      end

      if talk.abstract == 'intermission' && !talk.session_type_names.include?('Intermission')
        puts("#{talk.id} doesn't include 'Intermission': #{talk.session_type_names}")
      end

      if talk.type == 'SponsorSession' && !talk.session_type_names.include?('SponsorSession')
        puts("#{talk.id} doesn't include 'SponsorSession': #{talk.session_type_names}")
      end

      if talk.type == 'KeynoteSession' && !talk.session_type_names.include?('KeynoteSession')
        puts("#{talk.id} doesn't include 'KeynoteSession': #{talk.session_type_names}")
      end

      if talk.type == 'Intermission' && !talk.session_type_names.include?('Intermission')
        puts("#{talk.id} doesn't include 'Intermission': #{talk.session_type_names}")
      end

      if talk.type == 'Session' && !talk.session_type_names.include?('Session') && !talk.sponsor_session? && !talk.keynote? && !talk.intermission?
        puts("#{talk.id} doesn't include 'Session': #{talk.session_type_names}")
      end
    end
  end
end
