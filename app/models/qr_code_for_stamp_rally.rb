# == Schema Information
#
# Table name: stamp_rally_check_points
#
#  id            :string(26)       not null, primary key
#  type          :string(255)      not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint
#
# Indexes
#
#  index_stamp_rally_check_points_on_conference_id  (conference_id)
#  index_stamp_rally_check_points_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class QrCodeForStampRally
  include ActiveModel::Model
  attr_accessor :stamp_rally_check_point, :event

  def initialize(stamp_rally_check_point, event)
    @stamp_rally_check_point = stamp_rally_check_point
    @event = event
  end

  def url
    Rails.application.routes.url_helpers.new_stamp_rally_check_in_url(
      event: event.abbr,
      params: { stamp_rally_check_point: stamp_rally_check_point.id },
      host: Rails.application.default_url_options[:host]
    )
  end

  def url_qrcode_image
    Base64.strict_encode64(RQRCode::QRCode.new([{ data: url, mode: :byte_8bit }]).as_png.to_s)
  end
end
