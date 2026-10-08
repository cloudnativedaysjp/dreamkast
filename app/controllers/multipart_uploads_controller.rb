class MultipartUploadsController < UploadsController
  MAX_VIDEO_SIZE = 5.gigabytes
  DEFAULT_PART_SIZE = 64.megabytes

  before_action :require_video_uploader!
  before_action :set_upload, except: [:create]

  rescue_from ArgumentError, ActionController::ParameterMissing do
    head(:bad_request)
  end

  def create
    size = Integer(params.require(:size).to_s, 10)
    part_size = Integer(params.fetch(:partSize, DEFAULT_PART_SIZE).to_s, 10)
    return head(:payload_too_large) unless size.between?(1, MAX_VIDEO_SIZE)
    return head(:bad_request) unless part_size.between?(5.megabytes, DEFAULT_PART_SIZE)
    return head(:unsupported_media_type) unless %w[video/mp4 video/webm video/quicktime].include?(params[:type])

    current_user_model.with_lock do
      return head(:too_many_requests) if MultipartUpload.active.where(user: current_user_model).count >= 5

      key = "video_file/#{current_user_model.id}/#{SecureRandom.hex(24)}"
      result = client.create_multipart_upload(key: key, content_type: params[:type], content_disposition: 'attachment')
      begin
        MultipartUpload.create!(user: current_user_model, upload_id: result[:upload_id], key: key,
                                byte_size: size, part_size: part_size, expires_at: 24.hours.from_now)
      rescue StandardError
        client.abort_multipart_upload(upload_id: result[:upload_id], key: key)
        raise
      end
      render(json: { uploadId: result[:upload_id], key: key, partSize: part_size })
    end
  end

  def show
    render(json: client.list_parts(**upload_options).map { |part| { PartNumber: part[:part_number], Size: part[:size], ETag: part[:etag] } })
  end

  def sign
    number = Integer(params.require(:part_number).to_s, 10)
    render(json: signed_part(number))
  end

  def batch
    numbers = params.require(:partNumbers).to_s.split(',')
    return head(:bad_request) if numbers.empty? || numbers.size > 100

    urls = numbers.to_h { |number| [number, signed_part(Integer(number, 10))[:url]] }
    render(json: { presignedUrls: urls })
  end

  def complete
    @upload.with_lock do
      parts = client.list_parts(**upload_options).sort_by { |part| part[:part_number] }
      expected_count = (@upload.byte_size.to_f / @upload.part_size).ceil
      valid = parts.size == expected_count && parts.each_with_index.all? do |part, index|
        part[:part_number] == index + 1 && part[:size] == @upload.expected_part_size(index + 1)
      end
      unless valid
        client.abort_multipart_upload(**upload_options)
        @upload.destroy!
        return head(:unprocessable_entity)
      end
      result = client.complete_multipart_upload(**upload_options, parts: parts.map { |part| part.slice(:part_number, :etag) })
      @upload.destroy!
      render(json: result)
    end
  end

  def destroy
    @upload.with_lock do
      client.abort_multipart_upload(**upload_options)
      @upload.destroy!
    end
    render(json: {})
  end

  private

  def require_video_uploader!
    return head(:service_unavailable) unless Shrine.storages.key?(:video_file)

    head(:forbidden) unless current_user_model.speakers.exists? || current_user_model.admin_profiles.exists?
  end

  def set_upload
    @upload = MultipartUpload.active.where(user: current_user_model).find_by!(upload_id: params[:upload_id], key: params[:key])
  end

  def client
    @client ||= Uppy::S3Multipart::Client.new(bucket: Shrine.storages.fetch(:video_file).bucket)
  end

  def upload_options
    { upload_id: @upload.upload_id, key: @upload.key }
  end

  def signed_part(number)
    # SDK は Content-Length を既定で署名から除外するため、明示的に対象へ含める。
    client.prepare_upload_part(**upload_options, part_number: number, content_length: @upload.expected_part_size(number),
                                                 whitelist_headers: ['content-length'], expires_in: 15.minutes.to_i)
  end
end
