class VideoFileUploader < Shrine
  def generate_location(io, metadata: {}, **options)
    "video_file/#{super}"
  end
end
