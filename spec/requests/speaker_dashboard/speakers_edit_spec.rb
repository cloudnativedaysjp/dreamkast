require 'rails_helper'

describe SpeakerDashboard::SpeakersController, type: :request do
  admin_userinfo = { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => ['CNDT2020-Admin'] } } } }
  describe 'GET speakers#edit' do
    before do
      create(:cndt2020)
    end

    context "user doesn't log in" do
      context "user doesn't register" do
        context "get anyone's edit page" do
          it 'redirect to speaker_dashboard' do
            get '/cndt2020/speaker_dashboard/speakers/1/edit'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/cndt2020/speaker_dashboard'))
          end
        end
      end

      context 'user already registered' do
        before do
          create(:speaker_alice)
          create(:speaker_bob)
        end

        context 'get my edit page' do
          it 'redirect to speaker_dashboard' do
            get '/cndt2020/speaker_dashboard/speakers/1/edit'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/cndt2020/speaker_dashboard'))
          end
        end

        context "get other's edit page" do
          it 'redirect to speaker_dashboard' do
            get '/cndt2020/speaker_dashboard/speakers/2/edit'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to('/cndt2020/speaker_dashboard'))
          end
        end
      end
    end

    context 'user already logged in' do
      context "user doesn't registered" do
        before do
          allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo]))
          create(:speaker_bob)
        end

        context 'get others edit page' do
          it 'returns a 403' do
            get '/cndt2020/speaker_dashboard/speakers/2/edit'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('403'))
          end
        end
      end

      describe 'user already registered' do
        before do
          allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo]))
          create(:speaker_alice)
          create(:speaker_bob)
        end

        describe 'get my edit page' do
          it 'returns a success response with event top page' do
            get '/cndt2020/speaker_dashboard/speakers/1/edit'
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
          end
        end

        describe 'get others edit page' do
          it 'return 403' do
            get '/cndt2020/speaker_dashboard/speakers/2/edit'
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('403'))
          end
        end
      end
    end
  end

  describe 'GET speakers#edit セッション時間の選択肢' do
    let!(:conference) { create(:cndt2020) }
    # 本番と同じく、セッション時間の選択肢は同一の item_number にまとめる
    let!(:session_time_full) { create(:proposal_item_configs_session_time_40_min, conference:, item_number: 1) }
    let!(:session_time_keynote) { create(:proposal_item_configs_session_time_20_min, conference:, item_number: 1) }
    let!(:speaker) { create(:speaker_alice, :with_talk1_registered) }
    let(:talk) { speaker.talks.first }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(admin_userinfo[:userinfo]))
    end

    def session_time_radio(id)
      Nokogiri::HTML.parse(response.body).at_css("input.radio_button_session_times[value='#{id}']")
    end

    context '一般応募のTalkの場合' do
      it 'キーノート専用の選択肢だけが選択できない' do
        get '/cndt2020/speaker_dashboard/speakers/1/edit'
        expect(session_time_radio(session_time_full.id)['disabled']).to(be_nil)
        expect(session_time_radio(session_time_keynote.id)['disabled']).to(eq('disabled'))
      end
    end

    context 'キーノート招待されたTalkの場合' do
      before do
        talk.talk_types << create(:talk_type, :keynote)
      end

      it 'キーノート専用の選択肢も選択できる' do
        get '/cndt2020/speaker_dashboard/speakers/1/edit'
        expect(session_time_radio(session_time_keynote.id)['disabled']).to(be_nil)
      end

      context 'キーノート専用の時間が設定済みの場合' do
        before do
          talk.create_or_update_proposal_item('session_time', session_time_keynote.id.to_s)
          talk.save!
        end

        it 'セッション時間を変更できない' do
          get '/cndt2020/speaker_dashboard/speakers/1/edit'
          expect(session_time_radio(session_time_full.id)['disabled']).to(eq('disabled'))
          expect(session_time_radio(session_time_keynote.id)['disabled']).to(eq('disabled'))
        end
      end
    end
  end
end
