class Admin::ProposalsController < ApplicationController
  include SecuredAdmin
  include LogoutHelper

  def index
    @proposals = @conference.proposals
    respond_to do |format|
      format.html

      format.csv do
        head(:no_content)

        @talks = @conference.talks.order("conference_day_id ASC, start_time ASC, track_id ASC")
        filename = Talk.export_csv(@conference, @talks)
        stat = File.stat("./#{filename}.csv")
        send_file("./#{filename}.csv", filename: "#{filename}.csv", length: stat.size)
      end
    end
  end

  def update_proposals
    params[:proposal].each do |proposal_id, value|
      proposal = Proposal.find(proposal_id)
      proposal[:status] = value[:status].to_i
      proposal.save
    end
    redirect_to(admin_proposals_url, notice: "配信設定を更新しました")
  end
end
