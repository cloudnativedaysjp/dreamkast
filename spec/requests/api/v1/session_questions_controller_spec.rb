require 'rails_helper'

describe Api::V1::SessionQuestionsController, type: :request do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:alice) { create(:alice, :on_cndt2020, conference:) }
  let!(:bob) { create(:bob, :on_cndt2020, conference:) }
  let!(:public_profile_alice) { create(:public_profile, profile: alice, nickname: 'アリス') }
  let!(:public_profile_bob) { create(:public_profile, profile: bob, nickname: 'ボブ') }

  before do
    allow(JsonWebToken).to(receive(:verify).and_return(alice_claim))
  end

  describe 'GET /api/v1/talks/:talk_id/session_questions' do
    context 'when questions exist' do
      let!(:question1) { create(:session_question, talk:, conference:, profile: alice, votes_count: 5) }
      let!(:question2) { create(:session_question, talk:, conference:, profile: bob, votes_count: 10) }
      let!(:hidden_question) { create(:session_question, :hidden, talk:, conference:, profile: alice) }

      it 'returns questions successfully' do
        get "/api/v1/talks/#{talk.id}/session_questions"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['questions']).to be_an(Array)
        expect(json['questions'].length).to eq(2)
      end

      it 'excludes hidden questions' do
        get "/api/v1/talks/#{talk.id}/session_questions"
        json = JSON.parse(response.body)
        question_ids = json['questions'].map { |q| q['id'] }
        expect(question_ids).not_to include(hidden_question.id)
      end

      it 'uses profile.public_name for profile name' do
        get "/api/v1/talks/#{talk.id}/session_questions"
        json = JSON.parse(response.body)
        question = json['questions'].find { |q| q['id'] == question1.id }
        expect(question['profile']['name']).to eq('アリス')
      end

      context 'with sort=votes' do
        it 'sorts by votes_count desc' do
          get "/api/v1/talks/#{talk.id}/session_questions?sort=votes"
          json = JSON.parse(response.body)
          expect(json['questions'].first['id']).to eq(question2.id)
          expect(json['questions'].last['id']).to eq(question1.id)
        end
      end

      context 'with sort=time' do
        it 'sorts by created_at desc' do
          get "/api/v1/talks/#{talk.id}/session_questions?sort=time"
          json = JSON.parse(response.body)
          expect(json['questions'].first['id']).to eq(question2.id)
        end
      end
    end

    context 'when no questions exist' do
      it 'returns empty array' do
        get "/api/v1/talks/#{talk.id}/session_questions"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['questions']).to eq([])
      end
    end
  end

  describe 'POST /api/v1/talks/:talk_id/session_questions' do
    context 'with valid parameters' do
      it 'creates a question successfully' do
        expect {
          post "/api/v1/talks/#{talk.id}/session_questions",
               params: { body: '新しい質問です' },
               headers: { 'Content-Type' => 'application/json' }
        }.to change { SessionQuestion.count }.by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['body']).to eq('新しい質問です')
        expect(json['profile']['name']).to eq('アリス')
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'question_created')
        )

        post "/api/v1/talks/#{talk.id}/session_questions",
             params: { body: '新しい質問です' },
             headers: { 'Content-Type' => 'application/json' }
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post "/api/v1/talks/#{talk.id}/session_questions",
             params: { body: '' },
             headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end

    context 'without authentication' do
      before do
        allow(JsonWebToken).to(receive(:verify).and_raise(JWT::DecodeError))
      end

      it 'returns unauthorized' do
        post "/api/v1/talks/#{talk.id}/session_questions",
             params: { body: '質問' },
             headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/talks/:talk_id/session_questions/:id/vote' do
    let!(:question) { create(:session_question, talk:, conference:, profile: bob) }

    context 'when voting for the first time' do
      it 'creates a vote' do
        expect {
          post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"
        }.to change { SessionQuestionVote.count }.by(1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['has_voted']).to be true
        expect(json['votes_count']).to eq(1)
      end

      it 'allows voting on own question' do
        own_question = create(:session_question, talk:, conference:, profile: alice)
        post "/api/v1/talks/#{talk.id}/session_questions/#{own_question.id}/vote"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['has_voted']).to be true
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'question_voted', question_id: question.id)
        )

        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"
      end
    end

    context 'when unvoting' do
      before do
        create(:session_question_vote, session_question: question, profile: alice)
        question.update_votes_count!
      end

      it 'destroys the vote' do
        expect {
          post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"
        }.to change { SessionQuestionVote.count }.by(-1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['has_voted']).to be false
        expect(json['votes_count']).to eq(0)
      end
    end

    context 'when question is hidden' do
      let!(:hidden_question) { create(:session_question, :hidden, talk:, conference:, profile: bob) }

      it 'returns not found' do
        post "/api/v1/talks/#{talk.id}/session_questions/#{hidden_question.id}/vote"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
