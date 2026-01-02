require 'rails_helper'

describe TalksController, type: :request do
  let!(:conference) { create(:cndt2020, :opened, :cfp_result_visible) }
  let!(:talk) { create(:talk1, :accepted, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:public_profile) { create(:public_profile, profile:, nickname: 'アリス') }

  before do
    ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
      if arg[1] == :userinfo
        { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => [] } } }
      else
        arg[0].send(:original, arg[1])
      end
    end)
  end

  describe 'POST /:event/talks/:id/create_question' do
    context 'when user is logged in' do
      it 'creates a question successfully' do
        expect {
          post "/cndt2020/talks/#{talk.id}/create_question",
               params: { body: 'これは質問です' }
        }.to change { SessionQuestion.count }.by(1)

        expect(response).to redirect_to("/cndt2020/talks/#{talk.id}")
        follow_redirect!
        expect(response.body).to include('質問を投稿しました')
      end

      it 'broadcasts via ActionCable' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "qa_talk_#{talk.id}",
          hash_including(type: 'question_created')
        )

        post "/cndt2020/talks/#{talk.id}/create_question",
             params: { body: 'これは質問です' }
      end

      context 'with invalid parameters' do
        it 'shows validation errors' do
          post "/cndt2020/talks/#{talk.id}/create_question",
               params: { body: '' }

          expect(response).to redirect_to("/cndt2020/talks/#{talk.id}")
          follow_redirect!
          expect(response.body).to include("Bodyを入力してください")
        end
      end
    end

    context 'when user is not logged in' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(nil))
      end

      it 'does not create a question' do
        expect {
          post "/cndt2020/talks/#{talk.id}/create_question",
               params: { body: 'これは質問です' }
        }.not_to change { SessionQuestion.count }
      end
    end
  end

  describe 'GET /:event/talks/:id' do
    context 'when questions exist' do
      let!(:question1) { create(:session_question, talk:, conference:, profile:) }
      let!(:question2) { create(:session_question, talk:, conference:, profile:) }
      let!(:hidden_question) { create(:session_question, :hidden, talk:, conference:, profile:) }

      before do
        # original method is already defined in top-level before block
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
          if arg[1] == :userinfo
            { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => [] } } }
          else
            arg[0].send(:original, arg[1])
          end
        end)
      end

      it 'displays visible questions only' do
        get "/cndt2020/talks/#{talk.id}"
        expect(response).to be_successful
        expect(response.body).to include(question1.body)
        expect(response.body).to include(question2.body)
        # すべての質問が同じbodyを持つ可能性があるため、IDで判定する
        # hidden_question.idがレスポンスに含まれていないことを確認
        expect(response.body).not_to include("session_question_#{hidden_question.id}")
        expect(response.body).not_to include("question_#{hidden_question.id}")
      end

      it 'uses profile.public_name for profile name' do
        get "/cndt2020/talks/#{talk.id}"
        expect(response.body).to include('アリス')
      end
    end
  end
end
