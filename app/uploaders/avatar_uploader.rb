class AvatarUploader < Shrine
  def generate_location(io, metadata: {}, **options)
    "avatar/#{super}"
  end
end
