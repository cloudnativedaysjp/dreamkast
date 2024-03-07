require 'rails_helper'

describe TalksController, type: :request do
  subject(:session) {
    {
      userinfo: {
        info: {
          email: 'alice@example.com',
          extra: {
            sub: 'aaa'
          }
        },
        extra: {
          raw_info: {
            sub: 'aaa',
            'https://cloudnativedays.jp/roles' => roles
          }
        }
      }
    }
  }
  let(:roles) { [] }

  shared_examples_for :redirect_to_registration_page do |talk_id|
    it 'redirect to /cndt2020/registration' do
      get "/cndt2020/talks/#{talk_id}"
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to('/cndt2020/registration'))
    end
  end

  shared_examples_for :returns_success_response do |talk_id, talk_title, talk_abstract|
    it 'returns success response' do
      get "/cndt2020/talks/#{talk_id}"
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
      expect(response.body).to(include(talk_abstract))
      expect(response.body).to(include(talk_title))
    end
  end

  shared_examples_for :returns_not_found do |talk_id|
    it 'returns not found' do
      get "/cndt2020/talks/#{talk_id}"
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('404'))
    end
  end

  shared_examples_for :redirect_to_website do |talk_id|
    it 'redirect to website' do
      get "/cndt2020/talks/#{talk_id}"
      expect(response).to_not(be_successful)
      expect(response).to(have_http_status('302'))
      expect(response).to(redirect_to("https://cloudnativedays.jp/cndt2020/talks/#{talk_id}"))
    end
  end

  describe 'GET /cndt2020/talks/:id' do
    context 'timetable' do
      context 'show timetable' do
        let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible, :show_timetable) }
        let!(:talk1) { create(:talk1) }
        let!(:proposal1) { create(:proposal, conference: cndt2020, talk: talk1) }

        it 'includes timetable button' do
          get '/cndt2020/talks/1'
          expect(response).to(be_successful)
          expect(response.body).to(include('タイムテーブル'))
        end
      end

      context 'hide timetable' do
        let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible, :hide_timetable) }
        let!(:talk1) { create(:talk1) }
        let!(:proposal1) { create(:proposal, conference: cndt2020, talk: talk1) }

        it 'does not includes timetable button' do
          get '/cndt2020/talks/1'
          expect(response).to(be_successful)
          expect(response.body).not_to(include('タイムテーブル'))
        end
      end
    end

    context 'video archive' do
      let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }
      let!(:talk1) { create(:talk1) }
      let!(:proposal1) { create(:proposal, :accepted, conference: cndt2020, talk: talk1) }

      context 'display_video? is true' do
        before do
          allow_any_instance_of(TalksController).to(receive(:display_video?).and_return(true))
        end

        context 'video_id is empty' do
          let!(:video) { create(:video, talk: talk1, video_id: '') }

          it 'display waiting message' do
            get '/cndt2020/talks/1'
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('本セッションのアーカイブ動画は現在作成中です。'))
          end
        end

        context 'video_id is not empty' do
          let!(:video) { create(:video, talk: talk1, video_id: '122234') }

          it 'display video tag' do
            get '/cndt2020/talks/1'
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('<video'))
          end
        end
      end

      context 'display_video? is false' do
        before do
          allow_any_instance_of(TalksController).to(receive(:display_video?).and_return(false))
        end

        it 'display nothing' do
          get '/cndt2020/talks/1'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to_not(include('<video'))
          expect(response.body).to_not(include('本セッションのアーカイブ動画は現在作成中です。'))
        end
      end
    end

    context 'CNDT2020 is registered' do
      before do
        create(:talk_category1, conference: cndt2020)
        create(:talk_difficulties1, conference: cndt2020)
      end

      context "user doesn't logged in" do
        context 'cfp result is visible and proposal is accepted' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_success_response, 1, 'talk1', 'あいうえおかきくけこさしすせそ'
        end

        context 'cfp result is visible and proposal is rejected' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :rejected) }

          it_should_behave_like :returns_not_found, 1
        end

        context 'cfp result is invisible' do
          let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_not_found, 1
        end
      end

      context 'user logged in' do
        context "user doesn't registered" do
          before do
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return({ info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaa' } } }))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_registration_page, 1
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }

            it_should_behave_like :redirect_to_registration_page, 1
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_registration_page, 1
          end
        end

        context 'user already registered' do
          before do
            create(:alice, conference: cndt2020)
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_success_response, 2, 'talk2', 'あいうえおかきくけこさしすせそ'
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }
            let!(:talk2) { create(:talk2, :rejected) }

            it_should_behave_like :returns_not_found, 2
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :registered, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_not_found, 2
          end
        end
      end
    end

    context 'CNDT2020 is opened' do
      before do
        create(:talk_category1, conference: cndt2020)
        create(:talk_difficulties1, conference: cndt2020)
      end

      context "user doesn't logged in" do
        context 'cfp result is visible and proposal is accepted' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_success_response, 1, 'talk1', 'あいうえおかきくけこさしすせそ'
        end

        context 'cfp result is visible and proposal is rejected' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :rejected) }

          it_should_behave_like :returns_not_found, 1
        end

        context 'cfp result is invisible' do
          let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_invisible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_not_found, 1
        end
      end

      context 'user logged in' do
        context "user doesn't registered" do
          before do
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return({ info: { email: 'alice@example.com' } }))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_registration_page, 1
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }

            it_should_behave_like :redirect_to_registration_page, 1
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_registration_page, 1
          end
        end

        context 'user already registered' do
          before do
            create(:alice, conference: cndt2020)
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_success_response, 2, 'talk2', 'あいうえおかきくけこさしすせそ'
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }
            let!(:talk2) { create(:talk2, :rejected) }

            it_should_behave_like :returns_not_found, 2
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :opened, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_not_found, 2
          end
        end
      end
    end

    context 'CNDT2020 is closed' do
      before do
        create(:talk_category1, conference: cndt2020)
        create(:talk_difficulties1, conference: cndt2020)
      end

      context "user doesn't logged in" do
        context 'cfp result is visible and proposal is accepted' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_success_response, 1, 'talk1', 'あいうえおかきくけこさしすせそ'
        end

        context 'cfp result is visible and proposal is rejected' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :rejected) }

          it_should_behave_like :returns_not_found, 1
        end

        context 'cfp result is invisible' do
          let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_invisible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_not_found, 1
        end
      end

      context 'user logged in' do
        context "user doesn't registered" do
          before do
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return({ info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaa' } } }))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_registration_page, 1
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }

            it_should_behave_like :redirect_to_registration_page, 1
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_registration_page, 1
          end
        end

        context 'user already registered' do
          before do
            create(:alice, conference: cndt2020)
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_success_response, 2, 'talk2', 'あいうえおかきくけこさしすせそ'
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }
            let!(:talk2) { create(:talk2, :rejected) }

            it_should_behave_like :returns_not_found, 2
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :closed, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_not_found, 2
          end
        end
      end
    end

    context 'CNDT2020 is archived' do
      before do
        create(:talk_category1, conference: cndt2020)
        create(:talk_difficulties1, conference: cndt2020)
      end

      context "user doesn't logged in" do
        context 'cfp result is visible and proposal is accepted' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_success_response, 1, 'talk1', 'あいうえおかきくけこさしすせそ'
        end

        context 'cfp result is visible and proposal is rejected' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :rejected) }

          it_should_behave_like :returns_not_found, 1
        end

        context 'cfp result is invisible' do
          let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_invisible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :returns_not_found, 1
        end
      end

      context 'user logged in' do
        context "user doesn't registered" do
          before do
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return({ info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaa', 'https://cloudnativedays.jp/roles' => [] } } }))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :returns_success_response, 1, 'talk1', 'あいうえおかきくけこさしすせそ'
            # it_should_behave_like :redirect_to_registration_page, 1
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }

            it_should_behave_like :returns_not_found, 1
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :returns_not_found, 1
          end
        end

        context 'user already registered' do
          before do
            create(:alice, conference: cndt2020)
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_success_response, 2, 'talk2', 'あいうえおかきくけこさしすせそ'
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }
            let!(:talk2) { create(:talk2, :rejected) }

            it_should_behave_like :returns_not_found, 2
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :archived, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }
            let!(:talk2) { create(:talk2, :accepted) }

            it_should_behave_like :returns_not_found, 2
          end
        end
      end
    end

    context 'CNDT2020 is migrated' do
      before do
        create(:talk_category1, conference: cndt2020)
        create(:talk_difficulties1, conference: cndt2020)
      end

      context "user doesn't logged in" do
        context 'cfp result is visible and proposal is accepted' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :redirect_to_website, 1
        end

        context 'cfp result is visible and proposal is rejected' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }
          let!(:talk1) { create(:talk1, :rejected) }

          it_should_behave_like :redirect_to_website, 1
        end

        context 'cfp result is invisible' do
          let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_invisible) }
          let!(:talk1) { create(:talk1, :accepted) }

          it_should_behave_like :redirect_to_website, 1
        end
      end

      context 'user logged in' do
        context "user doesn't registered" do
          before do
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return({ info: { email: 'alice@example.com' } }))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_website, 1
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }

            it_should_behave_like :redirect_to_website, 1
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_website, 1
          end
        end

        context 'user already registered' do
          before do
            create(:alice, conference: cndt2020)
            allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
          end

          context 'cfp result is visible and proposal is accepted' do
            let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_website, 1
          end

          context 'cfp result is visible and proposal is rejected' do
            let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_visible) }
            let!(:talk1) { create(:talk1, :rejected) }

            it_should_behave_like :redirect_to_website, 1
          end

          context 'cfp result is invisible' do
            let!(:cndt2020) { create(:cndt2020, :migrated, :cfp_result_invisible) }
            let!(:talk1) { create(:talk1, :accepted) }

            it_should_behave_like :redirect_to_website, 1
          end
        end
      end
    end
  end
end
