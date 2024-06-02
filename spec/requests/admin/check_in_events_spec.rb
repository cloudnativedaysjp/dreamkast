require 'rails_helper'

describe Admin::CheckInEventsController, type: :request do
  let!(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  let!(:cndt2020) { create(:cndt2020) }
  let!(:alice) { create(:alice, :on_cndt2020) }

  describe 'POST /:event/admin/check_in_events' do
    subject { post(admin_check_in_events_path(event: 'cndt2020'), params: { check_in_event: params }, headers: { 'HTTP_REFERER' => admin_speaker_check_in_statuses_path(event: 'cndt2020') }) }

    context 'create' do
      let(:roles) { ['CNDT2020-Admin'] }
      let(:params) {
        {
          profile_id: alice.id,
          conference_id: cndt2020.id,
          check_in_timestamp: 1_715_483_605
        }
      }
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
      end

      it 'return ok' do
        subject

        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to(admin_speaker_check_in_statuses_path(event: 'cndt2020')))
      end
    end
  end
end
