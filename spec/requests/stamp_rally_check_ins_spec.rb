require 'rails_helper'

describe StampRallyCheckInsController, type: :request do
  let!(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'aaa' } }, extra: { raw_info: { sub: 'aaa', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  describe 'GET /stamp_rally_check_ins' do
    let!(:conference) { create(:cndt2020, :registered) }
    let!(:profile) { create(:alice, conference:) }
    let!(:sponsor) { create(:sponsor, conference:) }
    let!(:stamp_rally_check_point_booth) { create_list(:stamp_rally_check_point_booth, 2, conference:, sponsor:) }
    let!(:stamp_rally_check_point_finish) { create(:stamp_rally_check_point_finish, conference:) }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
    end

    context 'does not check in yet' do
      it 'returns a successful response' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response).to(have_http_status(:ok))
      end

      it 'include message: `スタンプラリーはまだ開始されていません`' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response.body).to(include('スタンプラリーはまだ開始されていません。'))
      end
    end

    context 'check in one booth' do
      let!(:stamp_rally_check_ins_booth) { create(:stamp_rally_check_in, profile:, stamp_rally_check_point: stamp_rally_check_point_booth[0], check_in_timestamp: DateTime.now) }

      it 'returns a successful response' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response).to(have_http_status(:ok))
      end

      it 'include message: `まだ回っていないCPがあります' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response.body).to(include('まだ回っていないCPがあります'))
      end
    end

    context 'check in all booth' do
      let!(:stamp_rally_check_ins) do
        stamp_rally_check_point_booth.map do |check_point|
          create(:stamp_rally_check_in, profile:, stamp_rally_check_point: check_point, check_in_timestamp: DateTime.now)
        end
      end

      it 'returns a successful response' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response).to(have_http_status(:ok))
      end

      it 'include message: `全てのCPを回り終わりました！受付でゴールしてください' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response.body).to(include('全てのCPを回り終わりました！受付でゴールしてください'))
      end
    end

    context 'check in all booth and finish' do
      let!(:stamp_rally_check_ins) do
        stamp_rally_check_point_booth.map do |check_point|
          create(:stamp_rally_check_in, profile:, stamp_rally_check_point: check_point, check_in_timestamp: DateTime.now)
        end
      end
      let!(:stamp_rally_check_ins_finish) { create(:stamp_rally_check_in, profile:, stamp_rally_check_point: stamp_rally_check_point_finish, check_in_timestamp: DateTime.now) }

      it 'returns a successful response' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response).to(have_http_status(:ok))
      end

      it 'include message: `ゴール！！' do
        get stamp_rally_check_ins_path(event: conference.abbr)
        expect(response.body).to(include('ゴール！！'))
      end
    end
  end
end
