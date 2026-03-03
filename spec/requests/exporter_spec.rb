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

    context 'CNK talk difficulties count by target conference' do
      let!(:cnk) { create(:conference, id: 15, abbr: 'cnk', name: 'クラウドネイティブ会議') }
      let!(:cnk_difficulty_beginner) { create(:talk_difficulty, id: 78, name: '初級者 - Beginner', conference: cnk) }
      let!(:cnk_difficulty_intermediate) { create(:talk_difficulty, id: 79, name: '中級者 - Intermediate', conference: cnk) }
      let!(:cnk_difficulty_expert) { create(:talk_difficulty, id: 80, name: '上級者 - Expert', conference: cnk) }

      let!(:cnk_talk1) do
        create(:talk, conference: cnk, talk_difficulty: cnk_difficulty_beginner, title: 'CND Talk 1')
      end
      let!(:cnk_talk2) do
        create(:talk, conference: cnk, talk_difficulty: cnk_difficulty_beginner, title: 'CND Talk 2')
      end
      let!(:cnk_talk3) do
        create(:talk, conference: cnk, talk_difficulty: cnk_difficulty_intermediate, title: 'PEK Talk 1')
      end
      let!(:cnk_talk4) do
        create(:talk, conference: cnk, talk_difficulty: cnk_difficulty_expert, title: 'SREK Talk 1')
      end

      before do
        # CND category proposal items
        create(:proposal_item, talk: cnk_talk1, conference: cnk, label: 'cnd_category', params: '234')
        create(:proposal_item, talk: cnk_talk2, conference: cnk, label: 'cnd_category', params: '235')
        # PEK category proposal item
        create(:proposal_item, talk: cnk_talk3, conference: cnk, label: 'pek_category', params: '257')
        # SREK category proposal item
        create(:proposal_item, talk: cnk_talk4, conference: cnk, label: 'srek_category', params: '269')

        # ProposalItemConfig(名称解決用)
        create(:proposal_item_config, id: 251, conference: cnk, type: 'ProposalItemConfigCheckBox',
               label: 'cnd_assumed_visitor', params: 'architect - システム設計')
        create(:proposal_item_config, id: 252, conference: cnk, type: 'ProposalItemConfigCheckBox',
               label: 'cnd_assumed_visitor', params: 'developer - システム開発')
        create(:proposal_item_config, id: 263, conference: cnk, type: 'ProposalItemConfigCheckBox',
               label: 'pek_assumed_visitor', params: 'Platform Engineer')
        create(:proposal_item_config, id: 221, conference: cnk, type: 'ProposalItemConfigCheckBox',
               label: 'execution_phase', params: 'Production(本番環境)')
        create(:proposal_item_config, id: 229, conference: cnk, type: 'ProposalItemConfigRadioButton',
               label: 'language', params: 'JA')
        create(:proposal_item_config, id: 230, conference: cnk, type: 'ProposalItemConfigRadioButton',
               label: 'language', params: 'EN')
        create(:proposal_item_config, id: 227, conference: cnk, type: 'ProposalItemConfigRadioButton',
               label: 'session_time', params: '_40min (full session)')
        create(:proposal_item_config, id: 223, conference: cnk, type: 'ProposalItemConfigRadioButton',
               label: 'whether_it_can_be_published', params: 'All okay - スライド・動画両方ともに公開可')

        # assumed_visitor (CheckBox - 配列)
        create(:proposal_item, talk: cnk_talk1, conference: cnk, label: 'cnd_assumed_visitor', params: ['251', '252'])
        create(:proposal_item, talk: cnk_talk2, conference: cnk, label: 'cnd_assumed_visitor', params: ['251'])
        create(:proposal_item, talk: cnk_talk3, conference: cnk, label: 'pek_assumed_visitor', params: ['263'])

        # execution_phase (CheckBox - 配列)
        create(:proposal_item, talk: cnk_talk1, conference: cnk, label: 'execution_phase', params: ['221'])
        create(:proposal_item, talk: cnk_talk3, conference: cnk, label: 'execution_phase', params: ['221'])

        # language (RadioButton - 文字列)
        create(:proposal_item, talk: cnk_talk1, conference: cnk, label: 'language', params: '229')
        create(:proposal_item, talk: cnk_talk2, conference: cnk, label: 'language', params: '229')
        create(:proposal_item, talk: cnk_talk3, conference: cnk, label: 'language', params: '230')

        # session_time (RadioButton)
        create(:proposal_item, talk: cnk_talk1, conference: cnk, label: 'session_time', params: '227')

        # whether_it_can_be_published (RadioButton)
        create(:proposal_item, talk: cnk_talk1, conference: cnk, label: 'whether_it_can_be_published', params: '223')
      end

      it 'returns CNK talk difficulties count by target conference' do
        get '/metrics'
        expect(response).to(be_successful)
        # CND: 2 talks with beginner difficulty
        expect(response.body).to(include('dreamkast_talk_difficulties_by_category_count{conference_id="15",target_conference="cnd_category",talk_difficulty_name="初級者 - Beginner"} 2.0'))
        # PEK: 1 talk with intermediate difficulty
        expect(response.body).to(include('dreamkast_talk_difficulties_by_category_count{conference_id="15",target_conference="pek_category",talk_difficulty_name="中級者 - Intermediate"} 1.0'))
        # SREK: 1 talk with expert difficulty
        expect(response.body).to(include('dreamkast_talk_difficulties_by_category_count{conference_id="15",target_conference="srek_category",talk_difficulty_name="上級者 - Expert"} 1.0'))
      end

      context 'when a talk has multiple category labels' do
        before do
          # cnk_talk1にPEKカテゴリも追加
          create(:proposal_item, talk: cnk_talk1, conference: cnk, label: 'pek_category', params: '258')
        end

        it 'counts the talk in each category' do
          get '/metrics'
          expect(response).to(be_successful)
          # CND: cnk_talk1 + cnk_talk2 = 2 talks with beginner
          expect(response.body).to(include('dreamkast_talk_difficulties_by_category_count{conference_id="15",target_conference="cnd_category",talk_difficulty_name="初級者 - Beginner"} 2.0'))
          # PEK: cnk_talk1(beginner) + cnk_talk3(intermediate) = それぞれカウント
          expect(response.body).to(include('dreamkast_talk_difficulties_by_category_count{conference_id="15",target_conference="pek_category",talk_difficulty_name="初級者 - Beginner"} 1.0'))
          expect(response.body).to(include('dreamkast_talk_difficulties_by_category_count{conference_id="15",target_conference="pek_category",talk_difficulty_name="中級者 - Intermediate"} 1.0'))
        end
      end

      it 'returns assumed visitors count by category' do
        get '/metrics'
        expect(response).to(be_successful)
        # CND: cnk_talk1(architect+developer), cnk_talk2(architect) -> architect=2, developer=1
        expect(response.body).to(include('dreamkast_assumed_visitors_by_category_count{conference_id="15",target_conference="cnd_category",assumed_visitor_name="architect - システム設計"} 2.0'))
        expect(response.body).to(include('dreamkast_assumed_visitors_by_category_count{conference_id="15",target_conference="cnd_category",assumed_visitor_name="developer - システム開発"} 1.0'))
        # PEK: cnk_talk3(Platform Engineer) -> 1
        expect(response.body).to(include('dreamkast_assumed_visitors_by_category_count{conference_id="15",target_conference="pek_category",assumed_visitor_name="Platform Engineer"} 1.0'))
      end

      it 'returns execution phases count by category' do
        get '/metrics'
        expect(response).to(be_successful)
        # CND: cnk_talk1 -> Production=1, PEK: cnk_talk3 -> Production=1
        expect(response.body).to(include('dreamkast_execution_phases_by_category_count{conference_id="15",target_conference="cnd_category",execution_phase_name="Production(本番環境)"} 1.0'))
        expect(response.body).to(include('dreamkast_execution_phases_by_category_count{conference_id="15",target_conference="pek_category",execution_phase_name="Production(本番環境)"} 1.0'))
      end

      it 'returns languages count by category' do
        get '/metrics'
        expect(response).to(be_successful)
        # CND: cnk_talk1(JA), cnk_talk2(JA) -> JA=2, PEK: cnk_talk3(EN) -> EN=1
        expect(response.body).to(include('dreamkast_languages_by_category_count{conference_id="15",target_conference="cnd_category",language_name="JA"} 2.0'))
        expect(response.body).to(include('dreamkast_languages_by_category_count{conference_id="15",target_conference="pek_category",language_name="EN"} 1.0'))
      end

      it 'returns session times count by category' do
        get '/metrics'
        expect(response).to(be_successful)
        # CND: cnk_talk1 -> 40min=1
        expect(response.body).to(include('dreamkast_session_times_by_category_count{conference_id="15",target_conference="cnd_category",session_time_name="_40min (full session)"} 1.0'))
      end

      it 'returns publication permissions count by category' do
        get '/metrics'
        expect(response).to(be_successful)
        # CND: cnk_talk1 -> All okay=1
        expect(response.body).to(include('dreamkast_publication_permissions_by_category_count{conference_id="15",target_conference="cnd_category",publication_permission_name="All okay - スライド・動画両方ともに公開可"} 1.0'))
      end

      it 'returns proposals count by category' do
        get '/metrics'
        expect(response).to(be_successful)
        # CND: cnk_talk1 + cnk_talk2 = 2, PEK: cnk_talk3 = 1, SREK: cnk_talk4 = 1
        expect(response.body).to(include('dreamkast_proposals_by_category_count{conference_id="15",target_conference="cnd_category"} 2.0'))
        expect(response.body).to(include('dreamkast_proposals_by_category_count{conference_id="15",target_conference="pek_category"} 1.0'))
        expect(response.body).to(include('dreamkast_proposals_by_category_count{conference_id="15",target_conference="srek_category"} 1.0'))
      end
    end
  end
end
