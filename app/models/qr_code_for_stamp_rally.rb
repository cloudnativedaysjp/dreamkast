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
      params: { stamp_rally_check_point_id: stamp_rally_check_point.id },
      protocol: protocol,
      host: Rails.application.default_url_options[:host]
    )
  end

  def protocol
    Rails.env.production? ? 'https' : 'http'
  end

  def url_qrcode_image
    Base64.strict_encode64(RQRCode::QRCode.new([{ data: url, mode: :byte_8bit }]).as_png(size: 300).to_s)
  end

  def h1_text
    case @stamp_rally_check_point.type
    when StampRallyCheckPoint.name
      'スタンプラリーチェックポイント'
    when StampRallyCheckPointBooth.name
      'スタンプラリーチェックポイント(ブース)'
    when StampRallyCheckPointFinish.name
      'スタンプラリーチェックポイント(ゴール)'
    else
      raise(NotImplementedError)
    end
  end
end
