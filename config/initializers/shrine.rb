require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/s3"

if Rails.env.development? || Rails.env.test?
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),
  }
else
  s3_options = {}
  if ENV['CLOUDCUBE_ACCESS_KEY_ID']
    s3_options = {
      access_key_id: ENV['CLOUDCUBE_ACCESS_KEY_ID'],
      secret_access_key: ENV['CLOUDCUBE_SECRET_ACCESS_KEY'],
      region: 'us-east-1',
      bucket: URI.parse(ENV['CLOUDCUBE_URL']).host.split('.')[0],
      prefix: URI.parse(ENV['CLOUDCUBE_URL']).path.slice(1...)
    }
  else
    s3_options = {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_ACCESS_KEY_ID'],
      region: ENV['S3_REGION'],
      bucket: ENV['S3_BUCKET']
    }
  end
  

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::S3.new(**s3_options),
  }
end


Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data