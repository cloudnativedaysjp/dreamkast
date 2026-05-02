require 'rails_helper'

describe Api::V1::SessionQuestionAnswersController, type: :request do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:speaker) { create(:speaker_alice, conference:) }
  let!(:question) { create(:session_question, talk:, conference:, profile:) }

  before do
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

    it 'includes answerer info' do
      get "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers"
      json = JSON.parse(response.body)
      expect(json['answers'].first['answerer']).to eq('type' => 'speaker', 'name' => speaker.name)
    end
  end

  describe 'POST /api/v1/talks/:talk_id/session_questions/:session_question_id/session_question_answers' do
    context 'when user is a speaker on the talk' do
      it 'creates an answer with speaker as answerer' do
        expect {
          post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
               params: { body: 'これは回答です' },
               as: :json
        }.to change { SessionQuestionAnswer.count }.by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['body']).to eq('これは回答です')
        expect(json['answerer']).to eq('type' => 'speaker', 'name' => speaker.name)

        answer = SessionQuestionAnswer.last
        expect(answer.speaker_id).to eq(speaker.id)
        expect(answer.sponsor_contact_id).to be_nil
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'answer_created', question_id: question.id)
        )

        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
             params: { body: 'これは回答です' },
             as: :json
      end
    end

    context 'when user is a sponsor contact for the talk\'s sponsor' do
      let!(:sponsor) { create(:sponsor, conference:) }
      let!(:sponsor_contact) do
        SponsorContact.create!(conference:, sponsor:, user_id: User.find_by!(sub: 'google-oauth2|alice').id)
      end

      before do
        # alice を該当 Talk のスピーカーから外し、Speaker レコード自体も削除して
        # SponsorContact ルートで認可されることを確認する
        talk.speakers.delete(speaker)
        speaker.destroy!
        talk.update!(sponsor:)
      end

      it 'creates an answer with sponsor_contact as answerer' do
        expect {
          post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
               params: { body: 'スポンサーからの回答' },
               as: :json
        }.to change { SessionQuestionAnswer.count }.by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['body']).to eq('スポンサーからの回答')
        expect(json['answerer']).to eq('type' => 'sponsor', 'name' => 'スポンサー担当者')

        answer = SessionQuestionAnswer.last
        expect(answer.speaker_id).to be_nil
        expect(answer.sponsor_contact_id).to eq(sponsor_contact.id)
      end
    end

    context 'when user is neither a speaker on the talk nor a sponsor contact' do
      let!(:non_speaker) { create(:speaker_bob, conference:) }

      before do
        talk.speakers.delete(speaker)
        talk.speakers << non_speaker
      end

      it 'returns forbidden' do
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
             params: { body: 'これは回答です' },
             as: :json

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Only speakers or sponsor contacts')
      end
    end

    context 'when user is a sponsor contact but for a different sponsor than the talk\'s' do
      let!(:other_sponsor) { create(:sponsor, conference:, id: 999, name: '別のスポンサー') }
      let!(:talk_sponsor) { create(:sponsor, conference:, id: 998, name: 'トークのスポンサー') }
      let!(:other_contact) do
        SponsorContact.create!(conference:, sponsor: other_sponsor, user_id: User.find_by!(sub: 'google-oauth2|alice').id)
      end

      before do
        talk.speakers.delete(speaker)
        speaker.destroy!
        talk.update!(sponsor: talk_sponsor)
      end

      it 'returns forbidden' do
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
             params: { body: '無関係な回答' },
             as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/session_question_answers",
             params: { body: '' },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end
end
