require 'rails_helper'

describe Admin::SpeakersController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  before do
    create(:cndt2020)
  end

  describe 'GET :event/admin/talks#index' do
    context "user doesn't logged in" do
      it 'redirect to login page' do
        get admin_talks_path(event: 'cndt2020')
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/auth/login?origin=/cndt2020/admin/talks'))
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
        it 'returns a forbidden response' do
          get admin_talks_path(event: 'cndt2020')
          expect(response).to(have_http_status('403'))
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

    describe 'talk is session' do
      let!(:talk1) { create(:talk1, :accepted, track_id: 1, conference_day_id: 1) }
      let!(:talk2) { create(:talk2, :accepted, track_id: 1, conference_day_id: 2) }

      describe 'If on air talk does not exists on track 1' do
        let!(:video1) { create(:video, talk: talk1, on_air: false) }
        let!(:video2) { create(:video, talk: talk2, on_air: false) }

        it 'success to change to start on air' do
          post admin_start_on_air_path(event: 'cndt2020'), params: { talk: { id: talk2.id } }.to_json, headers: { "Content-Type": 'application/json' }, as: :turbo_stream
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(Video.find(talk2.video.id).on_air).to(be_truthy)
        end
      end

      describe 'If on air talk exists on track 1' do
        let!(:video1) { create(:video, talk: talk1, on_air: true) }
        let!(:video2) { create(:video, talk: talk2, on_air: false) }

        it 'can not to change to start on air' do
          post admin_start_on_air_path(event: 'cndt2020'), params: { talk: { id: talk2.id } }.to_json, headers: { "Content-Type": 'application/json' }, as: :turbo_stream
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(Video.find(talk2.video.id).on_air).to(be_falsey)
          expect(flash[:alert]).to(include("Talk id=#{talk1.id} are already on_air."))
        end
      end
    end

    describe 'talk is intermission' do
      let!(:intermission1) { create(:intermission, track_id: 1, conference_day_id: 1) }
      let!(:intermission2) { create(:intermission, track_id: 1, conference_day_id: 2) }

      describe 'If on air talk exists on track 1' do
        let!(:video1) { create(:video, talk: intermission1, on_air: false) }
        let!(:video2) { create(:video, talk: intermission2, on_air: false) }

        it 'can not to change to start on air' do
          post admin_start_on_air_path(event: 'cndt2020'), params: { talk: { id: intermission2.id } }.to_json, headers: { "Content-Type": 'application/json' }, as: :turbo_stream
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(Video.find(intermission2.video.id).on_air).to(be_truthy)
        end
      end

      context 'exists on air talk is intermission' do
        let!(:video1) { create(:video, talk: intermission1, on_air: true) }
        let!(:video2) { create(:video, talk: intermission2, on_air: false) }

        it 'can not to change to start on air' do
          post admin_start_on_air_path(event: 'cndt2020'), params: { talk: { id: intermission2.id } }.to_json, headers: { "Content-Type": 'application/json' }, as: :turbo_stream
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
          expect(Video.find(intermission2.video.id).on_air).to(be_falsey)
          expect(flash[:alert]).to(include("Talk id=#{intermission1.id} are already on_air."))
        end
      end
    end
  end
end
