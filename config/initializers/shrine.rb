require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/s3'
require 'shrine/plugins/presign_endpoint'
require 'uppy/s3_multipart'

if Rails.env.development? || Rails.env.test? || ENV['AWS_ACCESS_KEY_ID']
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads'),
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
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['S3_REGION'],
      bucket: ENV['S3_BUCKET']
    }
  end

  Shrine.storages = {
    video_file: Shrine::Storage::S3.new(prefix: 'video_file', **s3_options),
    cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_options),
    store: Shrine::Storage::S3.new(**s3_options),
  }
end


Shrine.plugin(:activerecord)
Shrine.plugin(:cached_attachment_data)
Shrine.plugin(:restore_cached_data)
Shrine.plugin(:uppy_s3_multipart)
Shrine.plugin(:derivatives)
Shrine.plugin(:upload_endpoint, url: true)
Shrine.plugin(:backgrounding)
Shrine::Attacher.promote_block { PromoteJob.perform_now(record, name, file_data) }
Shrine::Attacher.destroy_block { DestroyJob.perform_later(data) }
