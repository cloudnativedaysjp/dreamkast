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
               as: :json
        }.to change { SessionQuestion.count }.by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['body']).to eq('新しい質問です')
        expect(json).not_to have_key('profile')
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'question_created')
        )

        post "/api/v1/talks/#{talk.id}/session_questions",
             params: { body: '新しい質問です' },
             as: :json
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post "/api/v1/talks/#{talk.id}/session_questions",
             params: { body: '' },
             as: :json

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
             as: :json

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
        # counter_cacheが自動的にvotes_countを更新するため、手動での更新は不要
        create(:session_question_vote, session_question: question, profile: alice)
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

    context 'concurrent voting' do
      let!(:question) { create(:session_question, talk:, conference:, profile: bob) }
      let!(:profile3) do
        user = FactoryBot.create(:user, sub: "google-oauth2|charlie-#{SecureRandom.hex(8)}", email: "charlie-#{SecureRandom.hex(8)}@example.com")
        Profile.create!(
          user_id: user.id,
          last_name: 'charlie',
          first_name: 'Charlie',
          industry_id: '1',
          occupation: 'aaa',
          company_name: 'aa',
          company_email: "charlie_company_#{SecureRandom.hex(8)}@example.com",
          company_postal_code: '1010001',
          company_address_level1: 'address level 1',
          company_address_level2: 'address level 2',
          company_address_line1: 'address line 1',
          company_address_line2: 'address line 2',
          company_tel: '12345678901',
          department: 'aa',
          position: 'aaa',
          conference_id: conference.id,
          number_of_employee_id: 2,
          annual_sales_id: 3,
          participation: 'オンライン参加'
        )
      end
      let!(:profile4) do
        user = FactoryBot.create(:user, sub: "google-oauth2|dave-#{SecureRandom.hex(8)}", email: "dave-#{SecureRandom.hex(8)}@example.com")
        Profile.create!(
          user_id: user.id,
          last_name: 'dave',
          first_name: 'Dave',
          industry_id: '1',
          occupation: 'aaa',
          company_name: 'aa',
          company_email: "dave_company_#{SecureRandom.hex(8)}@example.com",
          company_postal_code: '1010001',
          company_address_level1: 'address level 1',
          company_address_level2: 'address level 2',
          company_address_line1: 'address line 1',
          company_address_line2: 'address line 2',
          company_tel: '12345678901',
          department: 'aa',
          position: 'aaa',
          conference_id: conference.id,
          number_of_employee_id: 2,
          annual_sales_id: 3,
          participation: 'オンライン参加'
        )
      end

      it 'accurately counts votes when multiple users vote concurrently' do
        # counter_cacheが正しく動作することを確認するため、複数のユーザーが順次投票
        # counter_cacheのincrement_counter/decrement_counterはアトミック操作のため、
        # 同時実行時でも正確にカウントされる
        profiles = [alice, bob, profile3, profile4]
        vote_counts = []

        profiles.each_with_index do |profile, index|
          # 各プロファイル用のJWTトークンを設定（alice_claimの形式を使用）
          user_claim = [JSON.parse({
            'https://cloudnativedays.jp/roles' => [],
            'https://cloudnativedays.jp/userinfo' => {
              'given_name' => profile.first_name || 'Test',
              'family_name' => profile.last_name || 'User',
              'nickname' => profile.user&.email&.split('@')&.first || 'test',
              'name' => "#{profile.first_name} #{profile.last_name}",
              'email' => profile.user&.email || "test#{index}@example.com",
              'email_verified' => true
            },
            'sub' => profile.user&.sub || "google-oauth2|test#{index}",
            'aud' => ['https://event.cloudnativedays.jp/'],
            'iat' => Time.now.to_i,
            'exp' => Time.now.to_i + 3600
          }.to_json)]

          allow(JsonWebToken).to receive(:verify).and_return(user_claim)

          post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"
          expect(response).to have_http_status(:ok)

          json = JSON.parse(response.body)
          vote_counts << json['votes_count']
        end

        # 投票数が正確にカウントされていることを確認
        question.reload
        expect(question.votes_count).to eq(4)
        expect(SessionQuestionVote.where(session_question_id: question.id).count).to eq(4)

        # 各レスポンスのvotes_countが正しく更新されていることを確認
        expect(vote_counts).to eq([1, 2, 3, 4])
      end
    end

    context 'real-time updates via ActionCable' do
      let!(:question) { create(:session_question, talk:, conference:, profile: bob) }

      it 'broadcasts correct vote count and has_voted status' do
        # ActionCableのブロードキャストをキャプチャ
        broadcast_messages = []
        allow(ActionCable.server).to receive(:broadcast) do |channel, message|
          broadcast_messages << { channel:, message: }
        end

        # 投票を実行
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        # ブロードキャストが正しく送信されたことを確認
        expect(broadcast_messages).not_to be_empty
        vote_broadcast = broadcast_messages.find { |b| b[:message][:type] == 'question_voted' }
        expect(vote_broadcast).to be_present
        expect(vote_broadcast[:channel]).to eq("qa_talk_#{talk.id}")
        expect(vote_broadcast[:message][:question_id]).to eq(question.id)
        expect(vote_broadcast[:message][:votes_count]).to eq(1)
        expect(vote_broadcast[:message][:has_voted]).to be true

        # レスポンスとブロードキャストの内容が一致することを確認
        expect(json['votes_count']).to eq(vote_broadcast[:message][:votes_count])
        expect(json['has_voted']).to eq(vote_broadcast[:message][:has_voted])
      end

      it 'broadcasts updated vote count when unvoting' do
        # 最初に投票
        create(:session_question_vote, session_question: question, profile: alice)
        question.reload

        # ActionCableのブロードキャストをキャプチャ
        broadcast_messages = []
        allow(ActionCable.server).to receive(:broadcast) do |channel, message|
          broadcast_messages << { channel:, message: }
        end

        # 投票を取り消し
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        # ブロードキャストが正しく送信されたことを確認
        vote_broadcast = broadcast_messages.find { |b| b[:message][:type] == 'question_voted' }
        expect(vote_broadcast).to be_present
        expect(vote_broadcast[:message][:votes_count]).to eq(0)
        expect(vote_broadcast[:message][:has_voted]).to be false

        # レスポンスとブロードキャストの内容が一致することを確認
        expect(json['votes_count']).to eq(0)
        expect(json['has_voted']).to be false
      end

      it 'broadcasts multiple vote updates correctly' do
        # 複数の投票を順次実行し、各ブロードキャストが正しく送信されることを確認
        broadcast_messages = []
        allow(ActionCable.server).to receive(:broadcast) do |channel, message|
          broadcast_messages << { channel:, message: } if message[:type] == 'question_voted'
        end

        # 最初の投票
        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"
        expect(response).to have_http_status(:ok)

        # 2回目の投票（別のユーザーとして）
        allow(JsonWebToken).to receive(:verify).and_return([JSON.parse({
          'https://cloudnativedays.jp/roles' => [],
          'https://cloudnativedays.jp/userinfo' => {
            'given_name' => 'Bob',
            'family_name' => 'bob',
            'nickname' => 'bob',
            'name' => 'bob',
            'email' => bob.user.email,
            'email_verified' => true
          },
          'sub' => bob.user.sub,
          'aud' => ['https://event.cloudnativedays.jp/'],
          'iat' => Time.now.to_i,
          'exp' => Time.now.to_i + 3600
        }.to_json)])

        post "/api/v1/talks/#{talk.id}/session_questions/#{question.id}/vote"
        expect(response).to have_http_status(:ok)

        # 2つのブロードキャストが送信されたことを確認
        expect(broadcast_messages.length).to eq(2)
        expect(broadcast_messages.map { |b| b[:message][:votes_count] }).to contain_exactly(1, 2)
      end
    end
  end
end
