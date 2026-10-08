class UploadsController < ApplicationController
  MAX_AVATAR_SIZE = 10.megabytes
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze
  RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new

  rescue_from ActionController::InvalidAuthenticityToken do
    head(:unprocessable_entity)
  end

  before_action :require_upload_user!
  rate_limit to: 30, within: 1.minute, by: -> { current_user_model.id }, store: RATE_LIMIT_STORE

  def avatar
    file = params[:file]
    return head(:bad_request) unless file.is_a?(ActionDispatch::Http::UploadedFile)
    return head(:payload_too_large) if file.size > MAX_AVATAR_SIZE

    mime = Marcel::MimeType.for(file.tempfile)
    return head(:unsupported_media_type) unless ALLOWED_IMAGE_TYPES.include?(mime)

    uploaded = AvatarUploader.upload(file.tempfile, :cache, metadata: { 'mime_type' => mime })
    render(json: { data: uploaded.data, url: uploaded.url })
  end

  private

  def require_upload_user!
    head(:unauthorized) unless current_user_model
  end
end
