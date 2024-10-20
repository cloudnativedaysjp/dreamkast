class Admin::ProfilesController < ApplicationController
  include SecuredAdmin

  def index
    @profiles = Profile.where(conference_id: @conference.id)
  end

  def export_profiles
    profiles = Profile.export(@conference.id)
    filename = './tmp/profiles.csv'
    File.open(filename, 'w') do |file|
      file.write(profiles)
    end
    # ダウンロード
    stat = File.stat(filename)
    send_file(filename, filename: "profiles-#{Time.now.strftime("%F")}.csv", length: stat.size)
  end

  def entry_sheet
    @profile = Profile.find(params[:id])
    @speaker = conference.speakers.find_by(sub: @profile.sub)

    render('profiles/entry_sheet')
  end

  def print_entry_sheet
    auth = PrintNode::Auth.new(ENV['PRINTNODE_API_KEY'])
    client = PrintNode::Client.new(auth)

    printers = client.printers

    printer_id = printers[0].id
    pdf_path = "#{Rails.root}/test.pdf"

    pdf_content = File.read(pdf_path)
    pdf_base64 = Base64.strict_encode64(pdf_content)

    profile = Profile.find(print_entry_sheet_params[:profile_id])

    job = PrintNode::PrintJob.new(
      printer_id,
      "#{profile.email} エントリーシート",
      'pdf_base64',
      pdf_base64,
      'Dreamkast'
    )

    response = client.create_printjob(job)

    puts "印刷ジョブID: #{response.to_s}"

    respond_to do |format|
      flash.now[:notice] = "#{profile.email}  を印刷しました"
      format.turbo_stream
    end
  end

  def print_entry_sheet_params
    params.require(:print).permit(:id, :profile_id)
  end
end
