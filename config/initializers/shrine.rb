require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/s3"

if Rails.env.development? || Rails.env.test?
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),
  }
else
  s3_options = {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_ACCESS_KEY_ID'],
    region: ENV['S3_REGION'],
    bucket: ENV['S3_BUCKET']
  }

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
    store: Shrine::Storage::S3.new(**s3_options),
  }
end


Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data