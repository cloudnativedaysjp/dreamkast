class Video < ApplicationRecord
  include VideoFileUploader::Attachment(:video_file)

  belongs_to :talk

  def self.on_air(conference)
    current = conference.talks.accepted.map(&:video).select(&:on_air)
    list = {}
    list['current'] = []
    current.each do |video|
      if video.talk.track.present?
        list['current'][video.talk.track.number - 1] = {
          video_id: video.video_id,
          site: video.site,
          slido_id: video.slido_id,
          id: video.talk.id,
          title: video.talk.title,
          start_time: video.talk.start_time&.strftime("%H:%M"),
          end_time: video.talk.end_time&.strftime("%H:%M"),
          abstract: video.talk.abstract,
          track_name: video.talk.track.present? ? video.talk.track.name : '',
          track_number: video.talk.track.present? ? video.talk.track.number : '',
          track_id: video.talk.track_id,
          speakers: video.talk.speakers.map{|speaker| speaker.name}.join("/")
        }
      end
    end
    return list
  end

  def self.on_air_v2
    tracks = Track.where(conference_id: 2)
    res = {}
    on_air_talks = Talk.on_air.where(conference_id: 2)
    tracks.each do |track|
      talk = on_air_talks.find_by(track_id: track.id)
      if talk
        res[track.id] = {
          id: talk.id,
          trackId: talk.track_id,
          videoPlatform: track.video_platform,
          videoId: track.video_id,
          title: talk.title,
          abstract: talk.abstract,
          speakers: talk.speaker_names,
          dayId: talk.conference_day.present? ? talk.conference_day.id : 0,
          showOnTimetable: talk.show_on_timetable,
          startTime: talk.start_time,
          endTime: talk.end_time,
          talkDuration: talk.duration,
          talkDifficulty: talk.difficulty,
          talkCategory: talk.category,
          onAir: talk.on_air?,
          documentUrl: talk.document_url ? talk.document_url : '',
        }
      end
    end
    return res
  end
end
