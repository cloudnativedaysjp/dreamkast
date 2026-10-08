require 'rails_helper'

RSpec.describe(SpeakerDashboard::SpeakersController, type: :request) do
  admin_userinfo = { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => ['CNDT2020-Admin'] } } } }
  context 'user already logged in' do
    context "user doesn't registered" do
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

      describe 'register speaker and proposal without session time selection' do
        let(:conference) { create(:cndt2020, :registered, :speaker_entry_enabled) }
        let(:execution_phase) { create(:proposal_item_configs_execution_phase, conference:) }
        let(:assumed_visitor) { create(:proposal_item_configs_assumed_visitor, conference:) }
        let(:whether_it_can_be_published) { create(:proposal_item_configs_whether_it_can_be_published, :all_ok, conference:) }
        let(:presentation_method) { create(:proposal_item_configs_presentation_method, conference:) }
        let!(:regular_talk_attribute) { create(:talk_type, :session) }
        let(:talk_difficulty) { create(:talk_difficulties1, conference:) }

        it 'talk\'s session time should be 40 minutes (default value)' do
          params = {
            'name' => 'Takaishi Ryo',
            'name_mother_tongue' => '髙石 諒',
            'profile' => 'Hello',
            'company' => 'クラウドネイティブデイズ株式会社',
            'job_title' => '凄腕エンジニア',
            'additional_documents' => '',
            'twitter_id' => '',
            'github_id' => '',
            'avatar' => '',
            'conference_id' => conference.id,
            'talks_attributes' => {
              '1644323265675' =>
                {
                  'title' => 'すごいセッション',
                  'abstract' => 'すごいぞ！',
                  'talk_difficulty_id' => talk_difficulty.id,
                  'talk_types' => ['Session'],
                  'assumed_visitors' => [assumed_visitor.id],
                  'execution_phases' => [execution_phase.id],
                  'presentation_methods' => presentation_method.id,
                  'whether_it_can_be_publisheds' => whether_it_can_be_published.id,
                  '_destroy' => 'false',
                  'conference_id' => conference.id
                }
            }
          }
          post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020/speaker_dashboard'))

          speaker = Speaker.find_by(name: 'Takaishi Ryo')
          expect(speaker).to_not(be_nil)
          expect(speaker.proposals.size).to(eq(1))

          talk = speaker.talks.first
          expect(talk.time).to(eq(40))
          expect(talk.talk_types.pluck(:id)).to(include('Session'))
        end
      end

      describe '文字数制限のバリデーション' do
        let(:conference) { create(:cndt2020, :registered, :speaker_entry_enabled) }
        let(:execution_phase) { create(:proposal_item_configs_execution_phase, conference:) }
        let(:assumed_visitor) { create(:proposal_item_configs_assumed_visitor, conference:) }
        let(:whether_it_can_be_published) { create(:proposal_item_configs_whether_it_can_be_published, :all_ok, conference:) }
        let(:presentation_method) { create(:proposal_item_configs_presentation_method, conference:) }
        let!(:regular_talk_attribute) { create(:talk_type, :session) }
        let(:talk_difficulty) { create(:talk_difficulties1, conference:) }
        let(:base_params) do
          {
            'name' => 'Test Speaker',
            'name_mother_tongue' => 'テストスピーカー',
            'profile' => 'Test Profile',
            'company' => 'テスト会社',
            'job_title' => 'エンジニア',
            'additional_documents' => '',
            'twitter_id' => '',
            'github_id' => '',
            'avatar' => '',
            'conference_id' => conference.id,
            'talks_attributes' => {
              '1644323265675' =>
                {
                  'title' => 'テストタイトル',
                  'abstract' => 'テスト概要',
                  'talk_difficulty_id' => talk_difficulty.id,
                  'talk_types' => ['Session'],
                  'assumed_visitors' => [assumed_visitor.id],
                  'execution_phases' => [execution_phase.id],
                  'presentation_methods' => presentation_method.id,
                  'whether_it_can_be_publisheds' => whether_it_can_be_published.id,
                  '_destroy' => 'false',
                  'conference_id' => conference.id
                }
            }
          }
        end

        context 'タイトルが61文字の場合' do
          it 'バリデーションエラーになる' do
            params = base_params.deep_dup
            params['talks_attributes']['1644323265675']['title'] = 'あ' * 61

            post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('は60文字以内で入力してください'))
          end
        end

        context 'タイトルが60文字の場合' do
          it '正常に登録される' do
            params = base_params.deep_dup
            params['talks_attributes']['1644323265675']['title'] = 'あ' * 60

            post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

            expect(response).to(have_http_status('302'))
            speaker = Speaker.find_by(name: 'Test Speaker')
            expect(speaker).to_not(be_nil)
            expect(speaker.talks.first.title.each_grapheme_cluster.count).to(eq(60))
          end
        end

        context '概要が501文字の場合' do
          it 'バリデーションエラーになる' do
            params = base_params.deep_dup
            params['talks_attributes']['1644323265675']['abstract'] = 'あ' * 501

            post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('は500文字以内で入力してください'))
          end
        end

        context '概要が500文字の場合' do
          it '正常に登録される' do
            params = base_params.deep_dup
            params['talks_attributes']['1644323265675']['abstract'] = 'あ' * 500

            post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

            expect(response).to(have_http_status('302'))
            speaker = Speaker.find_by(name: 'Test Speaker')
            expect(speaker).to_not(be_nil)
            expect(speaker.talks.first.abstract.each_grapheme_cluster.count).to(eq(500))
          end
        end

        context 'タイトルが半角61文字の場合' do
          it 'バリデーションエラーになる' do
            params = base_params.deep_dup
            params['talks_attributes']['1644323265675']['title'] = 'a' * 61

            post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('は60文字以内で入力してください'))
          end
        end

        context '概要が半角501文字の場合' do
          it 'バリデーションエラーになる' do
            params = base_params.deep_dup
            params['talks_attributes']['1644323265675']['abstract'] = 'a' * 501

            post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

            expect(response).to(have_http_status('200'))
            expect(response.body).to(include('は500文字以内で入力してください'))
          end
        end

        context 'タイトルに絵文字が含まれる場合' do
          context '絵文字60個 = 60文字の場合' do
            it '正常に登録される' do
              params = base_params.deep_dup
              params['talks_attributes']['1644323265675']['title'] = '😀' * 60

              post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

              expect(response).to(have_http_status('302'))
              speaker = Speaker.find_by(name: 'Test Speaker')
              expect(speaker).to_not(be_nil)
              expect(speaker.talks.first.title.each_grapheme_cluster.count).to(eq(60))
            end
          end

          context '絵文字61個 = 61文字の場合' do
            it 'バリデーションエラーになる' do
              params = base_params.deep_dup
              params['talks_attributes']['1644323265675']['title'] = '😀' * 61

              post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

              expect(response).to(have_http_status('200'))
              expect(response.body).to(include('は60文字以内で入力してください'))
            end
          end

          context '複合絵文字（ゼロ幅結合子を含む）が含まれる場合' do
            it '正常に登録される（1文字としてカウント）' do
              params = base_params.deep_dup
              # 👨‍👩‍👧‍👦 は複数のコードポイントで構成されるが、1文字としてカウントされるべき
              params['talks_attributes']['1644323265675']['title'] = '👨‍👩‍👧‍👦' * 30

              post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

              expect(response).to(have_http_status('302'))
              speaker = Speaker.find_by(name: 'Test Speaker')
              expect(speaker).to_not(be_nil)
              expect(speaker.talks.first.title.each_grapheme_cluster.count).to(eq(30))
            end
          end
        end

        context '概要に絵文字が含まれる場合' do
          context '絵文字500個 = 500文字の場合' do
            it '正常に登録される' do
              params = base_params.deep_dup
              params['talks_attributes']['1644323265675']['abstract'] = '😀' * 500

              post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

              expect(response).to(have_http_status('302'))
              speaker = Speaker.find_by(name: 'Test Speaker')
              expect(speaker).to_not(be_nil)
              expect(speaker.talks.first.abstract.each_grapheme_cluster.count).to(eq(500))
            end
          end

          context '絵文字501個 = 501文字の場合' do
            it 'バリデーションエラーになる' do
              params = base_params.deep_dup
              params['talks_attributes']['1644323265675']['abstract'] = '😀' * 501

              post('/cndt2020/speaker_dashboard/speakers', params: { speaker: params })

              expect(response).to(have_http_status('200'))
              expect(response.body).to(include('は500文字以内で入力してください'))
            end
          end
        end
      end
    end
  end
end
