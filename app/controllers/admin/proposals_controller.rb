class Admin::ProposalsController < ApplicationController
  include SecuredAdmin

  def index
    @proposals = @conference.proposals
    respond_to do |format|
      format.html

      format.csv do
        @talks = @conference.talks.order('conference_day_id ASC, start_time ASC, track_id ASC')
        send_data(Talk.export_csv(@conference, @talks), filename: Talk.export_csv_filename(@conference), type: 'text/csv')
      end
    end
  end

  def update_proposals
    params[:proposal].each do |proposal_id, value|
      proposal = current_conference.proposals.find(proposal_id)
      proposal[:status] = value[:status].to_i
      proposal.save
    end
    redirect_to(admin_proposals_url, notice: '配信設定を更新しました')
  end
end
