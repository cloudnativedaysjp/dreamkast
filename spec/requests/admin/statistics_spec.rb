require 'rails_helper'

describe AdminController, type: :request do
  subject(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  before do
    create(:cndt2020)
  end

  describe 'GET :event/admin#statistics' do
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

      context 'user is registered' do
        before do
          create(:alice, :on_cndt2020)
        end

        context 'user is admin' do
          let(:roles) { ['CNDT2020-Admin'] }

          it 'returns a success response with statistics' do
            get admin_statistics_path(event: 'cndt2020')
            expect(response).to(be_successful)
            expect(response).to(have_http_status('200'))
          end

          context 'when check_in_talks contain duplicates for the same profile' do
            before do
              create(:talk1, :accepted)
              alice = Profile.find_by(first_name: 'Alice')
              talk = Talk.find(1)
              CheckInTalk.create!(profile: alice, talk:, check_in_timestamp: Time.current)
              CheckInTalk.create!(profile: alice, talk:, check_in_timestamp: Time.current)
            end

            it 'counts unique profiles per talk' do
              get admin_statistics_path(event: 'cndt2020')
              expect(response).to(have_http_status('200'))
              doc = Nokogiri::HTML.parse(response.body)
              row = doc.css('table.talks_table tbody tr').first
              # columns: ID, Title, 登録者数(現地), 登録者数(オンライン), チェックイン数, オンライン視聴数
              expect(row.css('td')[4].text.strip).to(eq('1'))
            end
          end
        end
      end
    end
  end
end
