require 'rails_helper'

describe Admin::SpeakersController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  before do
    create(:cndt2020)
  end

  describe 'GET :event/admin/talks#index' do
    context "user doesn't logged in" do
      it 'redirect to event top page' do
        get admin_talks_path(event: 'cndt2020')
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/cndt2020'))
      end
    end

    context 'user logged in' do
      before do
        ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
          if arg[1] == :userinfo
            session[:userinfo]
          else
            arg[0].send(:original, arg[1])
          end
        end)
      end

      context 'user is not registered' do
        it 'redirect to //registration' do
          skip 'TODO: `//registration` にリダイレクトされて名前解決できずにエラーになるので修正が必要'
          get admin_talks_path
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('//registration'))
        end
      end

      context 'user is registered' do
        before do
          create(:alice, :on_cndt2020)
        end

        context 'user is admin' do
          let(:roles) { ['CNDT2020-Admin'] }

          it 'returns a success response' do
            get admin_talks_path(event: 'cndt2020')
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
          end
        end

        context 'user is not admin' do
          it 'returns a success response' do
            get admin_talks_path(event: 'cndt2020')
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('403'))
          end
        end
      end
    end
  end


  describe 'POST :event/admin/talks#start_on_air' do
    let(:roles) { ['CNDT2020-Admin'] }
    let!(:talk1) { create(:talk1, track_id: 1, conference_day_id: 1) }
    let!(:talk2) { create(:talk2, track_id: 1, conference_day_id: 2) }
    let!(:video1) { create(:video, talk: talk1) }
    let!(:video2) { create(:video, talk: talk2) }

    before do
      ActionDispatch::Request::Session.define_method(:original, ActionDispatch::Request::Session.instance_method(:[]))
      allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]) do |*arg|
        if arg[1] == :userinfo
          session[:userinfo]
        else
          arg[0].send(:original, arg[1])
        end
      end)
    end

    describe 'If on air talk does not exists on track 1' do
      let!(:video1) { create(:video, talk: talk1) }
      let!(:video2) { create(:video, talk: talk2) }

      it 'success to change to start on air' do
        post admin_start_on_air_path(event: 'cndt2020'), params: { talk: { id: talk1.id }, format: 'js' }
        expect(response).to(be_successful)
        expect(Video.find(talk1.video.id).on_air).to(be_truthy)
      end
    end

    describe 'If on air talk does not exists on track 1'  do
      let!(:video1) { create(:video, talk: talk1, on_air: true) }
      let!(:video2) { create(:video, talk: talk2, on_air: false) }

      it 'can not to change to start on air' do
        post admin_start_on_air_path(event: 'cndt2020'), params: { talk: { id: talk2.id }, format: 'js' }.to_json, headers: { "Content-Type": 'application/json' }
        expect(response).to(be_successful)
        expect(Video.find(talk2.video.id).on_air).to(be_falsey)
        expect(response.body).to(include("Talk id=#{talk1.id} are already on_air."))
      end
    end
  end
end
