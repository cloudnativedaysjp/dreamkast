require 'rails_helper'

describe SponsorDashboards::SponsorContactsController, type: :request do
  admin_userinfo = { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaaa', 'https://cloudnativedays.jp/roles' => ['CNDT2020-Admin'] } } } }
  describe 'GET speaker_dashboards/:sponsor_id/sponsor_contacts#new' do
    let!(:cndt2020) { create(:cndt2020, :registered) }

    describe "user isn't sponsor's speaker" do
      let!(:sponsor) { create(:sponsor) }

      describe "sponsor contact isn't created yet" do
        describe "sponsor doesn't logged in" do
          it 'returns a success response with sponsor login page' do
            get '/cndt2020/sponsor_dashboards/1/sponsor_contacts/new'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/auth/login?origin=%2Fcndt2020%2Fsponsor_dashboards%2F1%2Fsponsor_contacts%2Fnew'))
          end
        end

        describe 'sponsor logged in' do
          before do
            ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
              if arg[1] == :userinfo
                admin_userinfo[:userinfo]
              else
                arg[0].send(:original, arg[1])
              end
            end)
          end

          it 'returns a success response with new sponsor_contacts page' do
            get '/cndt2020/sponsor_dashboards/1/sponsor_contacts/new'
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('スポンサー担当者情報フォーム(スポンサー1株式会社)'))
          end
        end
      end

      describe 'sponsor contact is created' do
        let!(:sponsor) { create(:sponsor) }
        # let!(:sponsor_contact) { create(:sponsor_alice, :on_cndt2020) }

        describe "sponsor doesn't logged in" do
          it 'returns a success response with sponsor login page' do
            get '/cndt2020/sponsor_dashboards/1/sponsor_contacts/new'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/auth/login?origin=%2Fcndt2020%2Fsponsor_dashboards%2F1%2Fsponsor_contacts%2Fnew'))
          end
        end

        describe 'sponsor logged in' do
          before do
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo]))
          end

          it 'returns a success response with new sponsor_contacts page' do
            get '/cndt2020/sponsor_dashboards/1/sponsor_contacts/new'
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('スポンサー担当者情報フォーム(スポンサー1株式会社)'))
          end
        end
      end
    end
  end
end
