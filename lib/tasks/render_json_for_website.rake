require 'json'
require 'erb'

namespace :util do
  desc 'render_json_for_website'
  task :render_json_for_website, ['abbr'] => :environment do |_, args|
    abbr = args.abbr

    Conference.where(abbr:).each do |conference|
      query = { show_on_timetable: true, conference_id: conference.id }
      @talks = Talk.includes([:conference, :conference_day, :talk_time, :talk_difficulty, :talk_category, :talks_speakers, :video, :speakers, :proposal]).where(query)
      @talks = if %w[cndt2020 cndo2021].include?(conference.abbr)
                 @talks.where.not(abstract: 'intermission').where.not(abstract: '-')
               else
                 @talks.where(proposals: { status: :accepted }).where.not(abstract: 'intermission').where.not(abstract: '-')
               end
      conference_days = conference.conference_days.filter { |day| !day.internal }.map(&:id)
      @talks = @talks.where(conference_days.map { |id| "conference_day_id = #{id}" }.join(' OR '))
      @talks = @talks.select do |talk|
        if talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL).present?
          if talk.proposal_items.empty?
            false
          else
            proposal_item = talk.proposal_items.find_by(label: VideoAndSlidePublished::LABEL) || []
            proposal_item.proposal_item_configs.map { |config| [VideoAndSlidePublished::ALL_OK, VideoAndSlidePublished::ONLY_VIDEO].include?(config.key.to_i) }.any? && talk.archived?
          end
        else
          (talk.video_published && talk.video.present? && talk.archived?)
        end
      end
      @speakers = @talks.map(&:speakers).flatten.uniq

      json_builder = Jbuilder.encode do |json|
        json.array!(@talks) do |talk|
          json.id(talk.id)
          json.conferenceId(talk.conference.id)
          json.trackId(talk.track_id)
          json.videoPlatform(talk.video_platform)
          json.videoId(talk.video_id)
          json.title(talk.title)
          json.abstract(talk.abstract)
          json.speakers(talk.speakers.map { |speaker| { id: speaker.id, name: speaker.name } })
          json.dayId(talk.conference_day.present? ? talk.conference_day.id : 0)
          json.showOnTimetable(talk.show_on_timetable)
          json.startTime(talk.start_time)
          json.endTime(talk.end_time)
          json.talkDuration(talk.duration)
          json.talkDifficulty(talk.difficulty)
          json.talkCategory(talk.category)
          json.onAir(talk.on_air?)
          json.documentUrl(talk.document_url || '')
          json.conferenceDayId(talk.conference_day&.id)
          json.conferenceDayDate(talk.conference_day&.date)
          json.presentationMethod(talk.presentation_method)
        end
      end
      puts json_builder
      json_obj = JSON.parse(json_builder)
      a = JSON.pretty_generate(json_obj)

      template = <<~EOS
        import type { Talk } from "../types/talk";

        export const <%= abbr.upcase %>Talks: Talk[] = <%= a %>
      EOS

      erb = ERB.new(template)
      File.open("#{abbr}_talks.ts", 'w') do |f|
        f.write(erb.result(binding))
      end

      json_builder = Jbuilder.encode do |json|
        json.array!(@speakers) do |speaker|
          json.id(speaker.id)
          json.name(speaker.name)
          json.company(speaker.company)
          json.jobTitle(speaker.job_title)
          json.profile(speaker.profile)
          json.githubId(speaker.github_id)
          json.twitterId(speaker.twitter_id)
          json.avatarUrl(speaker.avatar_url)
        end
      end

      json_obj = JSON.parse(json_builder)
      a = JSON.pretty_generate(json_obj)

      template = <<~EOS
        import type { Speaker } from "../types/speaker";

        export const <%= abbr.upcase %>Speakers: Speaker[] = <%= a %>
      EOS

      erb = ERB.new(template)
      File.open("#{abbr}_speakers.ts", 'w') do |f|
        f.write(erb.result(binding))
      end
    end
  end
end
