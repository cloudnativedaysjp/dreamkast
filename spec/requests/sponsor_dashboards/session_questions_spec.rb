require 'rails_helper'

RSpec.describe 'SponsorDashboards::SessionQuestions', type: :request do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_contact) { create(:sponsor_alice, conference:, sponsor:) }
  let!(:talk) { create(:talk1, conference:, sponsor:) }
  let!(:profile) { create(:bob, :on_cndt2020, conference:) }
  let!(:question) { create(:session_question, talk:, conference:, profile:, body: 'これは質問です') }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: sponsor_contact.email, name: sponsor_contact.name },
                                                                   extra: { raw_info: { sub: sponsor_contact.sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/session_questions' do
    it 'returns a successful response and lists the question' do
      get sponsor_dashboards_session_questions_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(be_successful)
      expect(response.body).to(include(talk.title))
      expect(response.body).to(include('これは質問です'))
    end

    context 'with unanswered=true filter' do
      let!(:speaker) { create(:speaker_alice, conference:, sponsor:) }
      let!(:answered_question) { create(:session_question, talk:, conference:, profile:, body: '回答済み質問') }
      let!(:answer_for_answered) { create(:session_question_answer, session_question: answered_question, speaker:, conference:) }

      it 'shows only unanswered questions' do
        get sponsor_dashboards_session_questions_path(event: conference.abbr, sponsor_id: sponsor.id, unanswered: 'true')
        expect(response).to(be_successful)
        expect(response.body).to(include('これは質問です'))
        expect(response.body).not_to(include('回答済み質問'))
      end

      it 'shows all questions when filter is off' do
        get sponsor_dashboards_session_questions_path(event: conference.abbr, sponsor_id: sponsor.id)
        expect(response.body).to(include('これは質問です'))
        expect(response.body).to(include('回答済み質問'))
      end
    end

    context 'with talk_id filter' do
      let!(:other_talk) { create(:talk2, conference:, sponsor:) }
      let!(:other_question) { create(:session_question, talk: other_talk, conference:, profile:, body: '別セッションの質問') }

      it 'shows only questions for the requested talk' do
        get sponsor_dashboards_session_questions_path(event: conference.abbr, sponsor_id: sponsor.id, talk_id: talk.id)
        expect(response.body).to(include('これは質問です'))
        expect(response.body).not_to(include('別セッションの質問'))
      end
    end

    context 'when sponsor_contact does not belong to the sponsor' do
      let!(:other_sponsor) { create(:sponsor, conference:, id: 2, name: '別スポンサー') }

      it 'returns 404' do
        get sponsor_dashboards_session_questions_path(event: conference.abbr, sponsor_id: other_sponsor.id)
        expect(response).to(have_http_status(:not_found))
      end
    end
  end

  describe 'POST /sponsor_dashboards/:sponsor_id/session_questions/:session_question_id/session_question_answers' do
    it 'creates an answer attributed to the sponsor_contact' do
      expect {
        post sponsor_dashboards_session_question_session_question_answers_path(
          event: conference.abbr, sponsor_id: sponsor.id, session_question_id: question.id
        ), params: { body: 'スポンサー担当者からの回答' }
      }.to(change { SessionQuestionAnswer.count }.by(1))

      answer = SessionQuestionAnswer.last
      expect(answer.sponsor_contact_id).to(eq(sponsor_contact.id))
      expect(answer.speaker_id).to(be_nil)
      expect(answer.body).to(eq('スポンサー担当者からの回答'))
      expect(response).to(redirect_to(sponsor_dashboards_session_questions_path(event: conference.abbr, sponsor_id: sponsor.id)))
    end

    context 'when question is not for one of this sponsor\'s talks' do
      let!(:other_talk) { create(:talk2, conference:) }
      let!(:other_question) { create(:session_question, talk: other_talk, conference:, profile:) }

      it 'returns 404' do
        post sponsor_dashboards_session_question_session_question_answers_path(
          event: conference.abbr, sponsor_id: sponsor.id, session_question_id: other_question.id
        ), params: { body: 'なりすまし' }
        expect(response).to(have_http_status(:not_found))
        expect(SessionQuestionAnswer.count).to(eq(0))
      end
    end

    context 'with blank body' do
      it 'does not create an answer' do
        expect {
          post sponsor_dashboards_session_question_session_question_answers_path(
            event: conference.abbr, sponsor_id: sponsor.id, session_question_id: question.id
          ), params: { body: '' }
        }.not_to(change { SessionQuestionAnswer.count })

        expect(flash[:alert]).to(include('回答の投稿に失敗しました'))
      end
    end
  end

  describe 'PATCH /sponsor_dashboards/:sponsor_id/session_questions/:id/toggle_hidden' do
    it 'hides a visible question' do
      expect {
        patch toggle_hidden_sponsor_dashboards_session_question_path(
          event: conference.abbr, sponsor_id: sponsor.id, id: question.id
        )
      }.to(change { question.reload.hidden }.from(false).to(true))

      expect(flash[:notice]).to(eq('質問を非表示にしました'))
      expect(response).to(redirect_to(sponsor_dashboards_session_questions_path(event: conference.abbr, sponsor_id: sponsor.id)))
    end

    it 'unhides a hidden question' do
      question.update!(hidden: true)
      expect {
        patch toggle_hidden_sponsor_dashboards_session_question_path(
          event: conference.abbr, sponsor_id: sponsor.id, id: question.id
        )
      }.to(change { question.reload.hidden }.from(true).to(false))

      expect(flash[:notice]).to(eq('質問を表示にしました'))
    end

    context 'when the question is for a different sponsor\'s talk' do
      let!(:other_talk) { create(:talk2, conference:) }
      let!(:other_question) { create(:session_question, talk: other_talk, conference:, profile:) }

      it 'returns 404 and does not change state' do
        patch toggle_hidden_sponsor_dashboards_session_question_path(
          event: conference.abbr, sponsor_id: sponsor.id, id: other_question.id
        )
        expect(response).to(have_http_status(:not_found))
        expect(other_question.reload.hidden).to(be(false))
      end
    end
  end
end
