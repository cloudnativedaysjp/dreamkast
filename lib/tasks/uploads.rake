namespace :uploads do
  desc '期限切れ multipart アップロードを中止する（定期実行用）'
  task cleanup: :environment do
    client = Uppy::S3Multipart::Client.new(bucket: Shrine.storages.fetch(:video_file).bucket)
    MultipartUpload.where(expires_at: ..Time.current).find_each do |upload|
      upload.with_lock do
        begin
          client.abort_multipart_upload(upload_id: upload.upload_id, key: upload.key)
        rescue Aws::S3::Errors::NoSuchUpload
          # S3 側のライフサイクル処理ですでに削除されている。
        end
        upload.destroy!
      end
    end
  end
end
