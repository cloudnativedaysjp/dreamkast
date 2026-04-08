require 'rails_helper'

def setup_logged_in_but_not_registered
  allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
end

def setup_logged_in_and_registered
  allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
  create(:alice, conference: cndt2020)
end

describe TalksController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  shared_examples_for :returns_success_response do
    it 'returns a success response' do
      get '/cndt2020/talks'
      expect(response).to(be_successful)
    end
  end

  shared_examples_for :redirect_to_proposals do
    it 'redirect to proposals' do
      get '/cndt2020/talks'
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to('/cndt2020/proposals'))
    end
  end

  shared_examples_for :redirect_to_registration do
    it 'redirect to /cndt2020/registration' do
      get '/cndt2020/talks'
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to('/cndt2020/registration'))
    end
  end

  shared_examples_for :redirect_to_website do
    it 'redirect to website' do
      get '/cndt2020/proposals'
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to('https://cloudnativedays.jp/cndt2020'))
    end
  end

  describe 'GET /:event/talks' do
    let!(:userinfo) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { 'https://cloudnativedays.jp/roles' => 'CNDT2020-Admin', sub: '' } } } } }

    context 'event is registered' do
      let!(:cndt2020) { create(:cndt2020, :registered) }

      context "user doesn't logged in" do
        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end

      context "logged in but user doesn't registered" do
        before { setup_logged_in_but_not_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }

          it_should_behave_like :redirect_to_registration
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_registration
        end
      end

      context 'logged in but speaker registered' do
        before {
          setup_logged_in_but_not_registered
          create(:speaker_alice, conference: cndt2020)
        }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end

      context 'logged in and registered' do
        before { setup_logged_in_and_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end
    end

    context 'event is opened' do
      let!(:cndt2020) { create(:cndt2020, :opened) }
      context "user doesn't logged in" do
        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end

      context "logged in but user doesn't registered" do
        before { setup_logged_in_but_not_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }

          it_should_behave_like :redirect_to_registration
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_registration
        end
      end

      context 'logged in but speaker registered' do
        before {
          setup_logged_in_but_not_registered
          create(:speaker_alice, conference: cndt2020)
        }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }

          it_should_behave_like :redirect_to_registration
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_registration
        end
      end

      context 'logged in and registered' do
        before { setup_logged_in_and_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end
    end

    context 'event is closed' do
      let!(:cndt2020) { create(:cndt2020, :closed) }
      context "user doesn't logged in" do
        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end

      context "logged in but user doesn't registered" do
        before { setup_logged_in_but_not_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }

          it_should_behave_like :redirect_to_registration
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_registration
        end
      end

      context 'logged in but speaker registered' do
        before {
          setup_logged_in_but_not_registered
          create(:speaker_alice, conference: cndt2020)
        }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }

          it_should_behave_like :redirect_to_registration
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_registration
        end
      end

      context 'logged in and registered' do
        before { setup_logged_in_and_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end
    end

    context 'event is archived' do
      let!(:cndt2020) { create(:cndt2020, :archived) }
      context "user doesn't logged in" do
        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_proposals
        end
      end

      context "logged in but user doesn't registered" do
        before { setup_logged_in_but_not_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_invisible) }

          it_should_behave_like :returns_success_response
        end
      end

      context 'logged in but speaker registered' do
        before {
          setup_logged_in_but_not_registered
          create(:speaker_alice, conference: cndt2020)
        }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_invisible) }

          it_should_behave_like :returns_success_response
        end
      end

      context 'logged in and registered' do
        before { setup_logged_in_and_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }

          it_should_behave_like :returns_success_response
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_invisible) }

          it_should_behave_like :returns_success_response
        end
      end
    end

    context 'event is migrated' do
      let!(:cndt2020) { create(:cndt2020, :migrated) }
      context "user doesn't logged in" do
        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }

          it_should_behave_like :redirect_to_website
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_website
        end
      end

      context "logged in but user doesn't registered" do
        before { setup_logged_in_but_not_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }

          it_should_behave_like :redirect_to_website
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_website
        end
      end

      context 'logged in but speaker registered' do
        before {
          setup_logged_in_but_not_registered
          create(:speaker_alice, conference: cndt2020)
        }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }

          it_should_behave_like :redirect_to_website
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_website
        end
      end

      context 'logged in and registered' do
        before { setup_logged_in_and_registered }

        context 'proposal result visible status is true' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }

          it_should_behave_like :redirect_to_website
        end

        context 'proposal result visible status is false' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_invisible) }

          it_should_behave_like :redirect_to_website
        end
      end
    end
  end
end
