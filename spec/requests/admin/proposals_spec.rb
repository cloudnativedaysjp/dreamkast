require 'rails_helper'

RSpec.describe(Admin::ProposalsController, type: :request) do
  let!(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { ['CNDT2020-Admin'] }
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:admin) { create(:alice, conference:) }
  let!(:talk) { create(:talk1, :accepted, track_id: 1, conference_day_id: 1) }
  let!(:proposal) { create(:proposal, conference:, talk:) }

  before do
    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
                                                                 if arg[1] == :userinfo
                                                                   session[:userinfo]
                                                                 else
                                                                   arg[0].send(:original, arg[1])
                                                                 end
                                                               end)
  end

  describe 'GET /admin/proposals' do
    it 'returns a successful response' do
      get admin_proposals_path(event: conference.abbr)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end

    it 'returns a CSV file when requested' do
      get admin_proposals_path(event: conference.abbr, format: :csv)
      expect(response).to(have_http_status('200'))
    end
  end

  describe 'PUT /admin/proposals' do
    let(:valid_attributes) do
      {
        proposal: {
          proposal.id.to_s => { status: '1' }
        }
      }
    end

    it 'updates the proposal status' do
      put admin_proposals_path(event: conference.abbr), params: valid_attributes
      expect(response).to(redirect_to(admin_proposals_url))
      expect(flash[:notice]).to(eq('配信設定を更新しました'))
      expect(Proposal.find(proposal.id).status).to(eq('accepted'))
    end
  end
end
