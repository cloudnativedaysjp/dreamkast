require 'rails_helper'

RSpec.describe(SpeakerDashboard::SpeakersController, type: :request) do
  admin_userinfo = { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'aaaa', 'https://cloudnativedays.jp/roles' => ['CNDT2020-Admin'] } } } }
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
        let(:execution_phase) { create(:proposal_item_configs_execution_phase, conference: conference) }
        let(:assumed_visitor) { create(:proposal_item_configs_assumed_visitor, conference: conference) }
        let(:whether_it_can_be_published) { create(:proposal_item_configs_whether_it_can_be_published, :all_ok, conference: conference) }
        let(:presentation_method) { create(:proposal_item_configs_presentation_method, conference: conference) }

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
                  'talk_difficulty_id' => '41',
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
        end
      end
    end
  end
end
