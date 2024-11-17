class PrintNode
  include ActiveModel::Model

  def initialize()
    auth = PrintNode::Auth.new(ENV['PRINTNODE_API_KEY'])
    @client = PrintNode::Client.new(auth)
  end

  def printers
    @client.printers
  end

  def print(file)
    pdf_content = File.read(file)
    pdf_base64 = Base64.strict_encode64(pdf_content)

    profile = Profile.find(profile_id)

    job = PrintNode::PrintJob.new(
      printer_id,
      "#{profile.email} エントリーシート",
      'pdf_base64',
      pdf_base64,
      'Dreamkast'
    )

    response = client.create_printjob(job)

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
