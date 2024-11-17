class GenerateEntrysheetJob < ApplicationJob
  queue_as :default
  # self.queue_adapter = :amazon_sqs

  def perform(conference_id, profile_id, speaker_id = nil)
    conference = Conference.find(conference_id)
    obj = { profile_id:, speaker_id: }.to_json

    encrypted = ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base.byteslice(0..31)).encrypt_and_sign(obj)

    page = Ferrum::Browser.new
    page.goto("http://#{Rails.application.routes.default_url_options[:host]}/#{conference.abbr}/entry_sheet?encrypted=#{Base64.urlsafe_encode64(encrypted)}")
    pdf_file = Rails.root.join('tmp', "#{profile_id}_entry_sheet.pdf")
    page.pdf(
      path: pdf_file,
      format: :A4,
      print_background: true,
      margin: { top: '0', bottom: '0', left: '0', right: '0' }
    )

    page.quit
  end
end
