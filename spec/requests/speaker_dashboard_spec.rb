require 'rails_helper'

describe SpeakerDashboardsController, type: :request do
  admin_userinfo = { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaaa', 'https://cloudnativedays.jp/roles' => ['CNDT2020-Admin'] } } } }
  describe 'GET speaker_dashboards#show' do
    shared_examples_for :request_is_successful do
      it 'request is successful' do
        get '/cndt2020/speaker_dashboard'
        expect(response).to(be_successful)
        expect(response).to(have_http_status('200'))
      end
    end

    shared_examples_for :response_includes_proposal_title_and_entry_status do |title, entry_status|
      it 'include information about proposal' do
        get '/cndt2020/speaker_dashboard'
        expect(response.body).to(include(title))
        expect(response.body).to(include(entry_status))
      end
    end

    shared_examples_for :response_does_not_include_proposal_title_and_entry_status do |title, entry_status|
      it 'include information about proposal' do
        get '/cndt2020/speaker_dashboard'
        expect(response.body).to_not(include(title))
        expect(response.body).to_not(include(entry_status))
      end
    end

    shared_examples_for :response_includes_edit_button do
      it 'include edit button ' do
        get '/cndt2020/speaker_dashboard'
        expect(response.body).to(include('edit'))
      end
    end

    context 'CNDT2020 is registered' do
      let!(:cndt2020) { create(:cndt2020, :registered) }

      describe "speaker doesn't logged in" do
        it 'returns a success response with speaker dashboard page' do
          get '/cndt2020/speaker_dashboard'
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(response.body).to(include('スピーカーダッシュボード'))
        end
      end

      describe 'speaker logged in' do
        before do
          allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(admin_userinfo))
        end

        describe "speaker doesn't registered" do
          it 'returns a success response with event top page' do
            get '/cndt2020/speaker_dashboard'
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('スピーカーダッシュボード'))
            expect(response.body).to(include('entry'))
          end
        end

        describe 'speaker registered' do
          before do
            create(:speaker_alice)
          end

          it 'response includes header text' do
            get '/cndt2020/speaker_dashboard'
            expect(response.body).to(include('スピーカーダッシュボード'))
          end
          it_should_behave_like :request_is_successful
          it_should_behave_like :response_includes_edit_button
        end
      end
    end

    context 'CNDT2020 is registered and speaker entry is enabled' do
      before do
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(admin_userinfo))
      end

      context 'CFP result is visible' do
        before do
          create(:cndt2020, :registered, :speaker_entry_enabled, :cfp_result_visible)
        end

        context "speaker doesn't have proposal" do
          before do
            create(:speaker_alice)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_does_not_include_proposal_title_and_entry_status, 'talk1', '受付状況'
          it_should_behave_like :response_includes_edit_button
        end

        context 'speaker has proposal and it is registered' do
          before do
            create(:speaker_alice, :with_talk1_registered)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_includes_proposal_title_and_entry_status, 'talk1', '受付状況: エントリー済み'
          it_should_behave_like :response_includes_edit_button
        end

        context 'speaker has proposal and it is accepted' do
          before do
            create(:speaker_alice, :with_talk1_accepted)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_includes_proposal_title_and_entry_status, 'talk1', '受付状況: 採択'
          it_should_behave_like :response_includes_edit_button
        end

        context 'speaker has proposal and it is rejected' do
          before do
            create(:speaker_alice, :with_talk1_rejected)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_includes_proposal_title_and_entry_status, 'talk1', '受付状況: 不採択'
          it_should_behave_like :response_includes_edit_button
        end
      end

      context 'CFP result is invisible' do
        before do
          create(:cndt2020, :registered, :speaker_entry_enabled, :cfp_result_invisible)
        end

        context "speaker doesn't have proposal" do
          before do
            create(:speaker_alice)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_does_not_include_proposal_title_and_entry_status, 'talk1', '受付状況'
          it_should_behave_like :response_includes_edit_button
        end

        context 'speaker has proposal and it is registered' do
          before do
            create(:speaker_alice, :with_talk1_registered)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_includes_proposal_title_and_entry_status, 'talk1', '受付状況: エントリー済み'
          it_should_behave_like :response_includes_edit_button
        end

        context 'speaker has proposal and it is accepted' do
          before do
            create(:speaker_alice, :with_talk1_accepted)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_includes_proposal_title_and_entry_status, 'talk1', '受付状況: エントリー済み'
          it_should_behave_like :response_includes_edit_button
        end

        context 'speaker has proposal and it is rejected' do
          before do
            create(:speaker_alice, :with_talk1_rejected)
          end

          it_should_behave_like :request_is_successful
          it_should_behave_like :response_includes_proposal_title_and_entry_status, 'talk1', '受付状況: エントリー済み'
          it_should_behave_like :response_includes_edit_button
        end
      end
    end
  end
end
