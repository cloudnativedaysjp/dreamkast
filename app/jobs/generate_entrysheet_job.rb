class GenerateEntrysheetJob < ApplicationJob
  queue_as :fifo
  self.queue_adapter = :amazon_sqs

  def perform(conference_id, profile_id, speaker_id = nil, printer_id = nil)
    conference = Conference.find(conference_id)
    obj = { profile_id:, speaker_id: }.to_json

    encrypted = ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base.byteslice(0..31)).encrypt_and_sign(obj)

    page = Ferrum::Browser.new({ browser_options: { 'no-sandbox': nil } })
    page.goto("http://#{Rails.application.routes.default_url_options[:host]}/#{conference.abbr}/entry_sheet?encrypted=#{Base64.urlsafe_encode64(encrypted)}")
    pdf_file = Rails.root.join('tmp', "#{profile_id}_entry_sheet.pdf")
    page.pdf(
      path: pdf_file,
      format: :A4,
      print_background: true,
      margin: { top: '0', bottom: '0', left: '0', right: '0' }
    )

    page.quit

    auth = PrintNode::Auth.new(ENV['PRINTNODE_API_KEY'])
    client = PrintNode::Client.new(auth)

    unless printer_id
      printers = client.printers
      printer_id = printers[0].id
    end

    pdf_content = File.read(pdf_file)
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

    puts("印刷ジョブID: #{response}")
  ensure
    File.exists?(pdf_file) && File.delete(pdf_file)
  end
end
