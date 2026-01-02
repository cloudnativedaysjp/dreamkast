require 'rails_helper'

describe Api::V1::SessionQuestionAnswersController, type: :request do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:speaker) { create(:speaker_alice, conference:) }
  let!(:question) { create(:session_question, talk:, conference:, profile:) }

  before do
    # スピーカーをトークに紐付ける
    talk.speakers << speaker
    allow(JsonWebToken).to(receive(:verify).and_return(alice_claim))
  end

  describe 'GET /api/v1/talks/:talk_id/session_questions/:session_question_id/session_question_answers' do
    let!(:answer1) { create(:session_question_answer, session_question: question, speaker:, conference:) }
    let!(:answer2) { create(:session_question_answer, session_question: question, speaker:, conference:) }

    it 'returns answers successfully' do
      get "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['answers']).to be_an(Array)
      expect(json['answers'].length).to eq(2)
    end

    it 'orders answers by created_at asc' do
      get "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers"
      json = JSON.parse(response.body)
      expect(json['answers'].first['id']).to eq(answer1.id)
      expect(json['answers'].last['id']).to eq(answer2.id)
    end
  end

  describe 'POST /api/v1/talks/:talk_id/session_questions/:session_question_id/session_question_answers' do
    context 'when user is a speaker' do
      it 'creates an answer successfully' do
        expect {
          post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
               params: { body: 'これは回答です' }.to_json,
               headers: { 'Content-Type' => 'application/json' }
        }.to change { SessionQuestionAnswer.count }.by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['body']).to eq('これは回答です')
        expect(json['speaker']['name']).to eq(speaker.name)
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'answer_created', question_id: question.id)
        )

        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
             params: { body: 'これは回答です' }.to_json,
             headers: { 'Content-Type' => 'application/json' }
      end
    end

    context 'when user is not a speaker' do
      let!(:non_speaker) { create(:speaker_bob, conference:) }

      before do
        talk.speakers.delete(speaker)
        talk.speakers << non_speaker
        # alice_claimはaliceのユーザーなので、speaker_aliceではない
        allow(JsonWebToken).to(receive(:verify).and_return(alice_claim))
      end

      it 'returns forbidden' do
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
             params: { body: 'これは回答です' }.to_json,
             headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Only speakers can answer questions')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
             params: { body: '' }.to_json,
             headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end
end
