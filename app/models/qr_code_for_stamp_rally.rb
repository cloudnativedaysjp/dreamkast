# == Schema Information
#
# Table name: stamp_rally_defs
#
#  id            :string(26)       not null, primary key
#  type          :string(255)      not null
#  conference_id :bigint           not null
#  sponsor_id    :bigint
#
# Indexes
#
#  index_stamp_rally_defs_on_conference_id  (conference_id)
#  index_stamp_rally_defs_on_sponsor_id     (sponsor_id)
#
# Foreign Keys
#
#  fk_rails_...  (conference_id => conferences.id)
#
class QrCodeForStampRally
  include ActiveModel::Model
  attr_accessor :stamp_rally_def, :event

  def initialize(stamp_rally_def, event)
    @stamp_rally_def = stamp_rally_def
    @event = event
  end

  def url
    Rails.application.routes.url_helpers.new_check_in_stamp_rally_url(
      event: event.abbr,
      params: { stamp_rally_def: stamp_rally_def.id },
      host: Rails.application.default_url_options[:host]
    )
  end

  def url_qrcode_image
    Base64.strict_encode64(RQRCode::QRCode.new([{ data: url, mode: :byte_8bit }]).as_png.to_s)
  end
end
