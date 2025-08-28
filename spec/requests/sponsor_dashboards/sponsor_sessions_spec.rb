require 'rails_helper'

RSpec.describe(SponsorDashboards::SponsorSessionsController, type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_contact) { create(:sponsor_alice, conference:, sponsor:) }
  let!(:speaker) { create(:speaker_alice, conference:, sponsor:) }
  let!(:talk_category) { create(:talk_category1, conference:) }
  let!(:talk_difficulty) { create(:talk_difficulties1, conference:) }
  let!(:check_box_config) { create(:proposal_item_configs_assumed_visitor, conference:) }
  let!(:radio_button_config) { create(:proposal_item_configs_presentation_method, conference:) }
  let!(:sponsor_talk_attribute) { create(:talk_type, :sponsor) }
  let!(:sponsor_session) { create(:sponsor_session, conference:, sponsor:, talk_category_id: talk_category.id, talk_difficulty_id: talk_difficulty.id) }

  before do
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(
                                                                 {
                                                                   info: { email: sponsor_contact.email, name: sponsor_contact.name },
                                                                   extra: { raw_info: { sub: sponsor_contact.sub, 'https://cloudnativedays.jp/roles' => [] } }
                                                                 }
                                                               ))
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_sessions' do
    it 'returns a successful response' do
      get sponsor_dashboards_sponsor_sessions_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_sessions/new' do
    it 'returns a successful response' do
      get new_sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: sponsor.id)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end
  end

  describe 'POST /sponsor_dashboards/:sponsor_id/sponsor_sessions' do
    let(:valid_attributes) do
      {
        sponsor_session: {
          sponsor_id: sponsor.id,
          conference_id: conference.id,
          title: 'New Sponsor Session',
          abstract: 'This is a test sponsor session',
          talk_category_id: talk_category.id,
          talk_difficulty_id: talk_difficulty.id,
          document_url: 'https://example.com/document',
          speaker_ids: [speaker.id],
          talk_types: ['sponsor'],
          proposal_items_attributes: {
            assumed_visitors: [check_box_config.id.to_s],
            presentation_methods: radio_button_config.id.to_s
          }
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new sponsor session' do
        expect {
          post(sponsor_dashboards_sponsor_sessions_path(event: conference.abbr, sponsor_id: sponsor.id), params: valid_attributes)
        }.to(change { Talk.where(sponsor_id: sponsor.id).count }.by(1))

        expect(flash.now[:notice]).to(eq('スポンサーセッションを登録しました'))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          sponsor_session: {
            sponsor_id: sponsor.id,
            conference_id: conference.id,
            title: '', # Invalid: title is required
            abstract: 'This is a test sponsor session',
            talk_category_id: talk_category.id,
            talk_difficulty_id: talk_difficulty.id,
            document_url: 'https://example.com/document',
            speaker_ids: [speaker.id],
            talk_types: ['sponsor'],
            proposal_items_attributes: {
              assumed_visitors: [check_box_config.id.to_s],
              presentation_methods: radio_button_config.id.to_s
            }
          }
        }
      end

      it 'does not create a new sponsor session' do
        expect {
          post(sponsor_dashboards_sponsor_sessions_path(event: conference.abbr, sponsor_id: sponsor.id), params: invalid_attributes)
        }.not_to(change { Talk.where(sponsor_id: sponsor.id).count })

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(flash.now[:alert]).to(eq('スポンサーセッションの登録に失敗しました'))
      end
    end
  end

  describe 'GET /sponsor_dashboards/:sponsor_id/sponsor_sessions/:id/edit' do
    it 'returns a successful response' do
      get edit_sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_session.id)
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
    end
  end

  describe 'PUT /sponsor_dashboards/:sponsor_id/sponsor_sessions/:id' do
    let(:valid_attributes) do
      {
        sponsor_session: {
          sponsor_id: sponsor.id,
          conference_id: conference.id,
          title: 'Updated Sponsor Session',
          abstract: 'This is an updated test sponsor session',
          talk_category_id: talk_category.id,
          talk_difficulty_id: talk_difficulty.id,
          document_url: 'https://example.com/updated-document',
          speaker_ids: [speaker.id],
          talk_types: ['sponsor'],
          proposal_items_attributes: {
            assumed_visitors: [check_box_config.id.to_s],
            presentation_methods: radio_button_config.id.to_s
          }
        }
      }
    end

    context 'with valid parameters' do
      it 'updates the sponsor session' do
        put(sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_session.id), params: valid_attributes)

        expect(flash.now[:notice]).to(eq('スポンサーセッションを更新しました'))
        sponsor_session.reload
        expect(sponsor_session.title).to(eq('Updated Sponsor Session'))
        expect(sponsor_session.abstract).to(eq('This is an updated test sponsor session'))
        expect(sponsor_session.document_url).to(eq('https://example.com/updated-document'))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          sponsor_session: {
            sponsor_id: sponsor.id,
            conference_id: conference.id,
            title: '', # Invalid: title is required
            abstract: 'This is an updated test sponsor session',
            talk_category_id: talk_category.id,
            talk_difficulty_id: talk_difficulty.id,
            document_url: 'https://example.com/updated-document',
            speaker_ids: [speaker.id],
            talk_types: ['sponsor'],
            proposal_items_attributes: {
              assumed_visitors: [check_box_config.id.to_s],
              presentation_methods: radio_button_config.id.to_s
            }
          }
        }
      end

      it 'does not update the sponsor session' do
        put(sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_session.id), params: invalid_attributes)

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(flash.now[:alert]).to(eq('スポンサーセッションの更新に失敗しました'))
      end
    end
  end

  describe 'DELETE /sponsor_dashboards/:sponsor_id/sponsor_sessions/:id' do
    it 'destroys the sponsor session' do
      expect {
        delete(sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_session.id),
               xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })
      }.to(change { Talk.where(sponsor_id: sponsor.id).count }.by(-1))

      expect(flash.now[:notice]).to(eq('スポンサーセッションを削除しました'))
    end

    context 'when deletion fails' do
      before do
        allow_any_instance_of(Talk).to(receive(:destroy).and_return(false))
      end

      it 'returns an error message' do
        delete(sponsor_dashboards_sponsor_session_path(event: conference.abbr, sponsor_id: sponsor.id, id: sponsor_session.id),
               xhr: true, headers: { Accept: 'text/vnd.turbo-stream.html' })

        expect(response).to(have_http_status(:unprocessable_entity))
        expect(flash.now[:alert]).to(eq('スポンサーセッションの削除に失敗しました'))
      end
    end
  end
end
