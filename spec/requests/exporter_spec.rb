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
    end
  end
end
