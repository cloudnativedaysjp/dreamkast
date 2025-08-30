require 'slack/incoming/webhooks'

namespace :util do
  desc 'check_talks'
  task check_talks: :environment do
    # ActiveRecord::Base.logger = Logger.new($stdout)
    Rails.logger.level = Logger::DEBUG
    Talk.all.each do |talk|
      # puts talk.id


      if talk.sponsor_session? && !talk.session_type_names.include?('SponsorSession')
        puts("#{talk.id} doesn't include 'SponsorSession': #{talk.session_type_names}")
      end

      if talk.talk_category&.name == 'Keynote' && !talk.session_type_names.include?('KeynoteSession')
        puts("#{talk.id} doesn't include 'KeynoteSession': #{talk.session_type_names}")
      end

      if talk.abstract == 'intermission' && !talk.session_type_names.include?('Intermission')
        puts("#{talk.id} doesn't include 'Intermission': #{talk.session_type_names}")
      end

      # if (talk.type == 'SponsorSession' || talk.sponsor.present?) && talk.session_type_names.sort != ['SponsorSession'].sort
      #   puts("#{talk.id} doesn't match ['SponsorSession']: #{talk.session_type_names}")
      # end

      # if talk.type == 'Session' && talk.session_type_names.sort != ['Session'].sort
      #   puts("#{talk.id} doesn't match ['Session']: #{talk.session_type_names}")
      # end

      # if (talk.type == 'KeynoteSession' || talk.talk_category&.name == 'Keynote') && talk.session_type_names.sort != ['KeynoteSession'].sort
      #   puts("#{talk.id} doesn't match ['KeynoteSession']: #{talk.session_type_names}")
      # end

      # if (talk.type == 'Intermission' || talk.abstract == 'intermission') && talk.session_type_names.sort != ['Intermission'].sort
      #   puts("#{talk.id} doesn't match ['Intermission']: #{talk.session_type_names}")
      # end
    end
  end
end
