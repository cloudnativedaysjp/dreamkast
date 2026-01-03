require 'rails_helper'

describe SpeakerDashboardsController, type: :request do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:speaker) { create(:speaker_alice, conference:) }
  let!(:public_profile) { create(:public_profile, profile:, nickname: 'アリス') }

  before do
    talk.speakers << speaker
    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
      if arg[1] == :userinfo
        { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => [] } } }
      else
        arg[0].send(:original, arg[1])
      end
    end)
  end

  describe 'GET /:event/speaker_dashboard' do
    context 'when unanswered questions exist' do
      let!(:question1) { create(:session_question, talk:, conference:, profile:) }
      let!(:question2) { create(:session_question, talk:, conference:, profile:) }
      let!(:answered_question) do
        q = create(:session_question, talk:, conference:, profile:)
        create(:session_question_answer, session_question: q, speaker:, conference:)
        q
      end
      let!(:hidden_question) { create(:session_question, :hidden, talk:, conference:, profile:) }

      it 'displays unanswered questions count' do
        get '/cndt2020/speaker_dashboard'
        expect(response).to be_successful
        expect(response.body).to include('未回答の質問: 2')
      end

      it 'excludes hidden questions' do
        get '/cndt2020/speaker_dashboard'
        # すべての質問が同じbodyを持つ可能性があるため、IDで判定する
        expect(response.body).not_to include("question_#{hidden_question.id}")
      end

      it 'excludes answered questions' do
        get '/cndt2020/speaker_dashboard'
        # すべての質問が同じbodyを持つ可能性があるため、IDで判定する
        expect(response.body).not_to include("question_#{answered_question.id}")
      end
    end
  end

  describe 'GET /:event/speaker_dashboard/questions' do
    let!(:question1) { create(:session_question, talk:, conference:, profile:) }
    let!(:question2) { create(:session_question, talk:, conference:, profile:) }
    let!(:hidden_question) { create(:session_question, :hidden, talk:, conference:, profile:) }

    it 'displays all questions' do
      get '/cndt2020/speaker_dashboard/questions'
      expect(response).to be_successful
      expect(response.body).to include(question1.body)
      expect(response.body).to include(question2.body)
    end

    it 'excludes hidden questions' do
      get '/cndt2020/speaker_dashboard/questions'
      # すべての質問が同じbodyを持つ可能性があるため、IDで判定する
      expect(response.body).not_to include("question_#{hidden_question.id}")
    end

    context 'with unanswered filter' do
      let!(:answered_question) do
        q = create(:session_question, talk:, conference:, profile:)
        create(:session_question_answer, session_question: q, speaker:, conference:)
        q
      end

      it 'filters unanswered questions only' do
        get '/cndt2020/speaker_dashboard/questions?unanswered=true'
        expect(response.body).to include(question1.body)
        # すべての質問が同じbodyを持つ可能性があるため、IDで判定する
        expect(response.body).to include("question_#{question1.id}")
        expect(response.body).not_to include("question_#{answered_question.id}")
      end
    end

    context 'with talk_id filter' do
      let!(:other_talk) { create(:talk2, conference:) }
      let!(:other_question) { create(:session_question, talk: other_talk, conference:, profile:) }

      it 'filters questions by talk_id' do
        get "/cndt2020/speaker_dashboard/questions?talk_id=#{talk.id}"
        expect(response.body).to include(question1.body)
        # question.id がHTMLに含まれているため、IDで判定する
        expect(response.body).to include("question_#{question1.id}")
        expect(response.body).not_to include("question_#{other_question.id}")
      end
    end
  end

  describe 'POST /:event/speaker_dashboard/talks/:talk_id/session_questions/:session_question_id/answers' do
    let!(:question) { create(:session_question, talk:, conference:, profile:) }

    context 'with valid parameters' do
      it 'creates an answer successfully' do
        expect {
          post "/cndt2020/speaker_dashboard/talks/#{talk.id}/session_questions/#{question.id}/answers",
               params: { body: 'これは回答です' },
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change { SessionQuestionAnswer.count }.by(1)

        expect(response).to have_http_status(:ok)
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'answer_created', question_id: question.id)
        )

        post "/cndt2020/speaker_dashboard/talks/#{talk.id}/session_questions/#{question.id}/answers",
             params: { body: 'これは回答です' },
             headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      end

      it 'responds with turbo_stream format' do
        post "/cndt2020/speaker_dashboard/talks/#{talk.id}/session_questions/#{question.id}/answers",
             params: { body: 'これは回答です' },
             headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context 'when speaker is not associated with talk' do
      let!(:other_talk) { create(:talk2, conference:) }
      let!(:other_question) { create(:session_question, talk: other_talk, conference:, profile:) }

      it 'returns error' do
        post "/cndt2020/speaker_dashboard/talks/#{other_talk.id}/session_questions/#{other_question.id}/answers",
             params: { body: 'これは回答です' }

        expect(response).to redirect_to('/cndt2020/speaker_dashboard')
        follow_redirect!
        expect(response.body).to include('このセッションの登壇者ではありません')
      end
    end
  end

  describe 'DELETE /:event/speaker_dashboard/talks/:talk_id/session_questions/:session_question_id/answers/:id' do
    let!(:question) { create(:session_question, talk:, conference:, profile:) }
    let!(:answer) { create(:session_question_answer, session_question: question, speaker:, conference:) }
    let!(:other_speaker) { create(:speaker_bob, conference:) }
    let!(:other_answer) do
      other_talk = create(:talk2, conference:)
      other_talk.speakers << other_speaker
      other_question = create(:session_question, talk: other_talk, conference:, profile:)
      create(:session_question_answer, session_question: other_question, speaker: other_speaker, conference:)
    end

    context 'when deleting own answer' do
      it 'deletes the answer successfully' do
        expect {
          delete "/cndt2020/speaker_dashboard/talks/#{talk.id}/session_questions/#{question.id}/answers/#{answer.id}",
                 headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change { SessionQuestionAnswer.count }.by(-1)

        expect(response).to have_http_status(:ok)
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'answer_deleted', question_id: question.id, answer_id: answer.id)
        )

        delete "/cndt2020/speaker_dashboard/talks/#{talk.id}/session_questions/#{question.id}/answers/#{answer.id}",
               headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      end
    end

    context 'when trying to delete other speaker answer' do
      it 'returns error' do
        delete "/cndt2020/speaker_dashboard/talks/#{other_answer.session_question.talk.id}/session_questions/#{other_answer.session_question.id}/answers/#{other_answer.id}"

        # other_talkは@speakerに関連付けられていないため、speaker_dashboard_pathにリダイレクトされる
        expect(response).to redirect_to('/cndt2020/speaker_dashboard')
        follow_redirect!
        expect(response.body).to include('このセッションの登壇者ではありません')
      end
    end
  end
end
