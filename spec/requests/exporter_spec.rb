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
  end
end
