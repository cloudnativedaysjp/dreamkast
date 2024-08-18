require 'rails_helper'

describe Admin::CheckInEventsController, type: :request do
  let!(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  let!(:cndt2020) { create(:cndt2020) }
  let!(:alice) { create(:alice, :on_cndt2020) }

  describe 'POST /:event/admin/check_in_events' do
    subject do
      post(admin_check_in_events_path(event: 'cndt2020'),
           params: {
             check_in_event: params
           },
           as: :turbo_stream)
    end

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
        ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
          if arg[1] == :userinfo
            session[:userinfo]
          else
            arg[0].send(:original, arg[1])
          end
        end)
      end

      it 'return ok' do
        subject

        expect(flash.now[:notice]).to(eq('alice Alice をチェックインしました'))
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
      end
    end
  end
end
