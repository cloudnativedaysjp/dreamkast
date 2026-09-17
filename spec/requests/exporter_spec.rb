require 'rails_helper'

describe DreamkastExporter, type: :request do
  context 'GET /metrics' do
    before do
      create(:talk1, conference: cndt2020)
      create(:talk3, conference: cndt2020)
      create_list(:messages, 10, :alice, :roomid1, profile: alice)
      create_list(:messages, 12, :bob, :roomid2, profile: bob)
      create_list(:viewer_count, 3, :talk1)
      create_list(:viewer_count, 3, :talk3)
      create(:video, :on_air, :talk1)
      create(:video, :on_air, :talk3)
    end
    after(:each) do
      FactoryBot.rewind_sequences
    end

    let!(:cndt2020) { create(:cndt2020, :opened) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:bob) { create(:bob, :on_cndt2020, conference: cndt2020) }

    it 'returns a success response with event top page' do
      get '/metrics'
      expect(response).to(be_successful)
      expect(response).to(have_http_status('200'))
      expect(response.body).to(include('dreamkast_track_viewer_count{track_id="1",conference_id="1"} 3.0'))
      expect(response.body).to(include('dreamkast_talk_viewer_count{talk_id="1",conference_id="1"} 3.0'))
      expect(response.body).to(include('dreamkast_chat_count{conference_id="1",talk_id="2"} 12.0'))
    end

    context 'have multiple profiles in each conference' do
      let!(:cndo2021) { create(:cndo2021, :registered) }
      let!(:alice) { create(:alice, :on_cndo2021, conference: cndo2021) }
      let!(:bob) { create(:bob, :on_cndt2020, conference: cndt2020) }
      it 'returns a number of regisrants each conferences' do
        get '/metrics'
        expect(response.body).to(include('dreamkast_registrants_count{conference_id="1"} 1.0'))
        expect(response.body).to(include('dreamkast_registrants_count{conference_id="2"} 1.0'))
      end
    end

    context 'have talks with categories' do
      let!(:cndw2026) { create(:conference, id: 16, abbr: 'cndw2026', name: 'CloudNative Days Winter 2026') }
      let!(:cnk2026) { create(:conference, id: 15, abbr: 'cnk2026', name: 'CloudNative Conference 2026') }

      before do
        existing_category = create(:talk_category, id: 1, conference: cndt2020, name: 'Existing Category')
        current_category = create(:talk_category, conference: cndw2026, name: 'Current Category')
        create(:talk_category, conference: cndw2026, name: 'Unused Category')
        special_category = create(:talk_category, conference: cnk2026, name: 'Special Category')

        create(:talk, conference: cndt2020, talk_category: existing_category, title: 'Existing Conference Talk')
        create_list(:talk, 2, conference: cndw2026, talk_category: current_category, title: 'Current Conference Talk')
        create(:talk, conference: cnk2026, talk_category: special_category, title: 'Special Conference Talk')
      end

      it 'returns talk counts by category except for conference 15' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_talk_categories_count{conference_id="1",talk_category_name="Existing Category"} 3.0'))
        expect(response.body).to(include('dreamkast_talk_categories_count{conference_id="16",talk_category_name="Current Category"} 2.0'))
        expect(response.body).to(include('dreamkast_talk_categories_count{conference_id="16",talk_category_name="Unused Category"} 0.0'))
        expect(response.body).not_to(include('dreamkast_talk_categories_count{conference_id="15"'))
      end
    end

    context 'have CFP proposals in a conference' do
      let!(:cndw2026) { create(:conference, id: 16, abbr: 'cndw2026', name: 'CloudNative Days Winter 2026') }
      let!(:beginner) { create(:talk_difficulty, conference: cndw2026, name: '初級者') }
      let!(:intermediate) { create(:talk_difficulty, conference: cndw2026, name: '中級者') }
      let!(:advanced) { create(:talk_difficulty, conference: cndw2026, name: '上級者') }

      before do
        session_type = TalkType.find(TalkType::SESSION_ID)
        sponsor_session_type = create(:talk_type, id: TalkType::SPONSOR_SESSION_ID, display_name: 'スポンサーセッション')

        cfp_talks = [beginner, intermediate].map.with_index do |difficulty, index|
          talk = create(:talk, conference: cndw2026, talk_difficulty: difficulty, title: "CFP Talk #{index + 1}")
          talk.talk_types << session_type
          create(:proposal, talk:, conference: cndw2026)
          talk
        end

        sponsor_talk = create(:talk, conference: cndw2026, talk_difficulty: beginner, title: 'Sponsor Talk')
        sponsor_talk.talk_types << sponsor_session_type
        create(:proposal, talk: sponsor_talk, conference: cndw2026)

        create_proposal_item_configs
        create_proposal_items(cfp_talks, sponsor_talk)
      end

      it 'returns only CFP proposal count for the conference' do
        get '/metrics'

        expect(response).to(be_successful)
        expect(response.body).to(include('dreamkast_cfp_proposals_count{conference_id="16"} 2.0'))
      end

      it 'returns CFP proposal counts by difficulty' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_difficulty_count{conference_id="16",talk_difficulty_name="初級者"} 1.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_difficulty_count{conference_id="16",talk_difficulty_name="中級者"} 1.0'))
      end

      it 'returns CFP proposal counts by assumed visitor' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_assumed_visitor_count{conference_id="16",assumed_visitor_name="architect"} 2.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_assumed_visitor_count{conference_id="16",assumed_visitor_name="developer"} 1.0'))
      end

      it 'returns CFP proposal counts by execution phase' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_execution_phase_count{conference_id="16",execution_phase_name="Dev/QA"} 1.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_execution_phase_count{conference_id="16",execution_phase_name="Production"} 1.0'))
      end

      it 'returns CFP proposal counts by publication permission' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_publication_permission_count{conference_id="16",publication_permission_name="All okay"} 1.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_publication_permission_count{conference_id="16",publication_permission_name="Only slide"} 1.0'))
      end

      it 'returns CFP proposal counts by session time' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_session_time_count{conference_id="16",session_time_name="30 minutes"} 1.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_session_time_count{conference_id="16",session_time_name="20 minutes"} 1.0'))
      end

      it 'returns CFP proposal counts by language' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_language_count{conference_id="16",language_name="JA"} 1.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_language_count{conference_id="16",language_name="EN"} 1.0'))
      end

      it 'returns CFP proposal counts by presentation method' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_presentation_method_count{conference_id="16",presentation_method_name="onsite"} 1.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_presentation_method_count{conference_id="16",presentation_method_name="online"} 1.0'))
      end

      it 'returns zero for choices and difficulties without any proposal' do
        get '/metrics'

        expect(response.body).to(include('dreamkast_cfp_proposals_by_presentation_method_count{conference_id="16",presentation_method_name="hybrid"} 0.0'))
        expect(response.body).to(include('dreamkast_cfp_proposals_by_difficulty_count{conference_id="16",talk_difficulty_name="上級者"} 0.0'))
      end

      def create_proposal_item_configs
        create(:proposal_item_config, id: 283, conference: cndw2026, label: 'assumed_visitor', params: 'architect')
        create(:proposal_item_config, id: 284, conference: cndw2026, label: 'assumed_visitor', params: 'developer')
        create(:proposal_item_config, id: 289, conference: cndw2026, label: 'execution_phase', params: 'Dev/QA')
        create(:proposal_item_config, id: 291, conference: cndw2026, label: 'execution_phase', params: 'Production')
        create(:proposal_item_config, id: 293, conference: cndw2026, label: 'whether_it_can_be_published', params: 'All okay')
        create(:proposal_item_config, id: 294, conference: cndw2026, label: 'whether_it_can_be_published', params: 'Only slide')
        create(:proposal_item_config, id: 299, conference: cndw2026, label: 'session_time', params: '30 minutes')
        create(:proposal_item_config, id: 300, conference: cndw2026, label: 'session_time', params: '20 minutes')
        create(:proposal_item_config, id: 301, conference: cndw2026, label: 'language', params: 'JA')
        create(:proposal_item_config, id: 302, conference: cndw2026, label: 'language', params: 'EN')
        create(:proposal_item_config, id: 297, conference: cndw2026, label: 'presentation_method', params: 'onsite')
        create(:proposal_item_config, id: 298, conference: cndw2026, label: 'presentation_method', params: 'online')
        # 応募が 1 件も無い選択肢（ゼロ埋めの確認用）
        create(:proposal_item_config, id: 303, conference: cndw2026, label: 'presentation_method', params: 'hybrid')
      end

      def create_proposal_items(cfp_talks, sponsor_talk)
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[0], label: 'assumed_visitor', params: %w[283 284])
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[1], label: 'assumed_visitor', params: ['283'])
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[0], label: 'execution_phase', params: ['289'])
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[1], label: 'execution_phase', params: ['291'])
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[0], label: 'whether_it_can_be_published', params: '293')
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[1], label: 'whether_it_can_be_published', params: '294')
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[0], label: 'session_time', params: '299')
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[1], label: 'session_time', params: '300')
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[0], label: 'language', params: '301')
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[1], label: 'language', params: '302')
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[0], label: 'presentation_method', params: '297')
        create(:proposal_item, conference: cndw2026, talk: cfp_talks[1], label: 'presentation_method', params: '298')
        create(:proposal_item, conference: cndw2026, talk: sponsor_talk, label: 'language', params: '301')
      end
    end
  end
end
