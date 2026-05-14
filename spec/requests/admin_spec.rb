require 'rails_helper'

describe AdminController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  before do
    create(:cndt2020)
  end

  describe 'GET admin#show' do
    context "user doesn't logged in" do
      it 'redirect to event top page' do
        get admin_path(event: 'cndt2020')
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/auth/login?origin=/cndt2020/admin'))
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
          get admin_path(event: 'cndt2020')
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
            get admin_path(event: 'cndt2020')
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
          end

          context 'when check_in_conferences contain duplicates and online participants' do
            before do
              create(:bob, :on_cndt2020, participation: 'offline')
              conference = Conference.find_by(abbr: 'cndt2020')
              alice = Profile.find_by(first_name: 'Alice')
              bob = Profile.find_by(first_name: 'Bob')
              CheckInConference.create!(profile: bob, conference:, check_in_timestamp: Time.current)
              CheckInConference.create!(profile: bob, conference:, check_in_timestamp: Time.current)
              CheckInConference.create!(profile: alice, conference:, check_in_timestamp: Time.current)
            end

            it 'counts unique offline profiles only' do
              get admin_path(event: 'cndt2020')
              expect(response).to(have_http_status('200'))
              doc = Nokogiri::HTML.parse(response.body)
              count_card = doc.css('.bg-success .card-text').text.strip
              expect(count_card).to(eq('1'))
            end
          end
        end

        context 'user is not admin' do
          it 'returns a success response' do
            get admin_path(event: 'cndt2020')
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('403'))
          end
        end
      end
    end
  end

  describe 'GET admin#users' do
    context "user doesn't logged in" do
      it 'redirect to login page' do
        get admin_users_path(event: 'cndt2020')
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/auth/login?origin=/cndt2020/admin/users'))
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
          get admin_users_path(event: 'cndt2020')
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
            get admin_users_path(event: 'cndt2020')
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
          end
        end

        context 'user is not admin' do
          it 'returns a success response' do
            get admin_users_path(event: 'cndt2020')
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('403'))
          end
        end
      end
    end
  end
end
