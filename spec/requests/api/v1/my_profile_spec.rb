require 'rails_helper'

describe Api::V1::ProfilesController, type: :request do
  describe 'GET /api/v1/:eventAbbr/my_profile' do
    let!(:conference) { create(:cndt2020, :opened) }
    let!(:profile) { create(:alice, :on_cndt2020, conference:) }

    before do
      allow(JsonWebToken).to(receive(:verify).and_return(alice_claim))
    end

    it 'confirms json schema' do
      get '/api/v1/cndt2020/my_profile'
      assert_response_schema_confirm(200)
    end

    it 'returns userId' do
      get '/api/v1/cndt2020/my_profile'
      json = JSON.parse(response.body)
      expect(json['userId']).to(eq(profile.user_id))
      expect(json['userId']).to(be_present)
    end
  end
end
