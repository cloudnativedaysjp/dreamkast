class Track < ApplicationRecord
  has_many :talks
  has_one :streaming

  belongs_to :room, optional: true

  def on_air_talk
    on_air_talks = talks.includes(:video).map(&:video).select { |v| v && v.on_air }
    if on_air_talks.nil?
      return nil
    end
    if on_air_talks.size >= 2
      raise(Exception)
    end
    if on_air_talks.size == 0
      return nil
    end
    on_air_talks.first
  end
end
