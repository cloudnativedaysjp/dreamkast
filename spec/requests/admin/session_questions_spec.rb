require 'rails_helper'

describe Admin::SessionQuestionsController, type: :request do
  subject(:session) {
    {
      userinfo: {
        info: {
          email: 'alice@example.com'
        },
        extra: {
          raw_info: {
            sub: 'google-oauth2|alice',
            'https://cloudnativedays.jp/roles' => roles
          }
        }
      }
    }
  }
  let(:roles) { ['CNDT2020-Admin'] }
  let!(:conference) { create(:cndt2020) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:public_profile) { create(:public_profile, profile:, nickname: 'アリス') }

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

  describe 'GET /:event/admin/session_questions' do
    let!(:question1) { create(:session_question, talk:, conference:, profile:) }
    let!(:question2) { create(:session_question, talk:, conference:, profile:) }

    it 'returns success response' do
      get "/cndt2020/admin/session_questions"
      expect(response).to be_successful
      expect(response.body).to include(question1.body)
      expect(response.body).to include(question2.body)
    end

    context 'with talk_id filter' do
      let!(:other_talk) { create(:talk2, conference:) }
      let!(:other_question) { create(:session_question, talk: other_talk, conference:, profile:) }

      it 'filters questions by talk_id' do
        get "/cndt2020/admin/session_questions?talk_id=#{talk.id}"
        expect(response.body).to include(question1.body)
        expect(response.body).not_to include(other_question.body)
      end
    end

    context 'with sort=votes' do
      let!(:question1) { create(:session_question, talk:, conference:, profile:, votes_count: 5) }
      let!(:question2) { create(:session_question, talk:, conference:, profile:, votes_count: 10) }

      it 'sorts by votes_count desc' do
        get "/cndt2020/admin/session_questions?sort=votes"
        # HTMLレスポンスなので、bodyの順序を確認
        expect(response.body.index(question2.body)).to be < response.body.index(question1.body)
      end
    end
  end

  describe 'GET /:event/admin/session_questions/:id' do
    let!(:question) { create(:session_question, talk:, conference:, profile:) }
    let!(:answer) { create(:session_question_answer, session_question: question, speaker: create(:speaker_alice, conference:), conference:) }

    it 'returns question details' do
      get "/cndt2020/admin/session_questions/#{question.id}"
      expect(response).to be_successful
      expect(response.body).to include(question.body)
      expect(response.body).to include('アリス')
    end

    it 'displays answers' do
      get "/cndt2020/admin/session_questions/#{question.id}"
      expect(response.body).to include(answer.body)
    end
  end

  describe 'PATCH /:event/admin/session_questions/:id/toggle_hidden' do
    let!(:question) { create(:session_question, talk:, conference:, profile:, hidden: false) }

    context 'when toggling to hidden' do
      it 'sets hidden to true' do
        expect {
          patch "/cndt2020/admin/session_questions/#{question.id}/toggle_hidden"
          question.reload
        }.to change { question.hidden }.from(false).to(true)

        expect(response).to redirect_to("/cndt2020/admin/session_questions/#{question.id}")
        follow_redirect!
        expect(response.body).to include('質問を非表示にしました')
      end
    end

    context 'when toggling to visible' do
      let!(:question) { create(:session_question, :hidden, talk:, conference:, profile:) }

      it 'sets hidden to false' do
        expect {
          patch "/cndt2020/admin/session_questions/#{question.id}/toggle_hidden"
          question.reload
        }.to change { question.hidden }.from(true).to(false)

        expect(response).to redirect_to("/cndt2020/admin/session_questions/#{question.id}")
        follow_redirect!
        expect(response.body).to include('質問を表示にしました')
      end
    end
  end
end
