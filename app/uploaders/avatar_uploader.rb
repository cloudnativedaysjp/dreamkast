require 'image_processing/vips'

class AvatarUploader < Shrine
  THUMBNAILS = {
    large:  [300, 300],
    medium: [120, 120],
    small:  [80, 80]
  }.freeze

  def generate_location(io, metadata: {}, **options)
    "avatar/#{super}"
  end

  # S3 への upload 時には Content-Type が指定されないため
  # File の mime-type から設定する
  # https://shrinerb.com/rdoc/classes/Shrine/Storage/S3.html
  plugin :upload_options, store: lambda { |io, _context|
    mime = if io.respond_to?(:metadata)
             io.metadata['mime_type']
           else
             Marcel::Magic.by_magic(io).type
           end
    { content_type: mime }
  }

  Attacher.derivatives do |original|
    magick = ImageProcessing::Vips.source(original)
    magick = magick.crop(*file.crop_points)
    THUMBNAILS.transform_values do |(width, height)|
      magick.resize_to_limit!(width, height)
    end
  end

  class UploadedFile
    attr_reader :metadata

    def crop_points
      metadata.fetch('crop').fetch_values('x', 'y', 'width', 'height')
    end
  end
end
