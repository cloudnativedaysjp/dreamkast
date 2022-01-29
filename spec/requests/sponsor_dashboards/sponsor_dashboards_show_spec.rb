require 'rails_helper'

describe SponsorDashboards::SponsorDashboardsController, type: :request do
  admin_userinfo = { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaaa', 'https://cloudnativedays.jp/roles' => ['CNDT2020-Admin'] } } } }
  describe 'GET sponsor_dashboards#show' do
    let!(:cndt2020) { create(:cndt2020, :registered) }

    shared_examples_for :redirect_to_login_page do
      it 'redirect to login page' do
        get '/cndt2020/sponsor_dashboards/1'
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020/sponsor_dashboards/login'))
      end
    end

    shared_examples_for :returns_successfully do
      it 'returns successfully' do
        get '/cndt2020/sponsor_dashboards/1'
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
        expect(response.body).to(include('スポンサーダッシュボード'))
      end
    end

    shared_examples_for :response_includes_proposal_title_and_entry_status do |title, entry_status|
      it 'include information about proposal' do
        get '/cndt2020/sponsor_dashboards/1'
        expect(response.body).to(include(title))
        expect(response.body).to(include(entry_status))
      end
    end

    shared_examples_for :response_does_not_include_proposal_title do |title|
      it 'include information about proposal' do
        get '/cndt2020/sponsor_dashboards/1'
        expect(response.body).to_not(include(title))
      end
    end

    describe "user isn't sponsor's speaker" do
      let!(:sponsor) { create(:sponsor) }

      describe "sponsor profile isn't created yet" do
        describe "sponsor doesn't logged in" do
          it_should_behave_like :redirect_to_login_page
        end

        describe 'sponsor logged in' do
          before { allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo])) }

          it_should_behave_like :redirect_to_login_page
        end
      end
    end

    describe "user is sponsor's speaker" do
      let!(:sponsor) { create(:sponsor, conference: cndt2020) }

      describe "sponsor profile isn't created yet" do
        describe "sponsor doesn't logged in" do
          it_should_behave_like :redirect_to_login_page
        end

        describe 'sponsor logged in' do
          before { allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo])) }

          it_should_behave_like :redirect_to_login_page
        end
      end

      describe 'sponsor profile is already created' do
        let!(:sponsor_alice) { create(:sponsor_alice) }

        describe "sponsor doesn't logged in" do
          it_should_behave_like :redirect_to_login_page
        end

        describe 'sponsor logged in' do
          before { allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo])) }

          it_should_behave_like :returns_successfully

          context 'sponsor has sponsor session and has registered proposal ' do
            before do
              create(:talks_speakers, { talk: talk, speaker: speaker })
              create(:proposal, :with_cndt2021, talk: talk, status: 0)
            end
            let(:speaker) { create(:speaker_alice, :with_talk1_registered) }
            let(:talk) { create(:sponsor_session, sponsor: sponsor) }

            it_should_behave_like :returns_successfully
            it_should_behave_like :response_does_not_include_proposal_title, 'talk1'
            it_should_behave_like :response_includes_proposal_title_and_entry_status, 'sponsor_session', '受付状況: エントリー済み'
          end
        end
      end
    end
  end
end
