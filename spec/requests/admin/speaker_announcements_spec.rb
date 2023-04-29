require 'rails_helper'

describe Admin::SpeakerAnnouncementsController, type: :request do
  let!(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'alice' } }, extra: { raw_info: { sub: 'alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  before { create(:cndt2020) }

  describe 'GET :event/admin/speaker_announcements#index' do
    subject { get(admin_speaker_announcements_path(event: 'cndt2020')) }
    context "user doesn't logged in" do
      it 'redirect to login page' do
        subject
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/auth/login?origin=/cndt2020/admin/speaker_announcements'))
      end
    end

    context 'user logged in' do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(session[:userinfo]))
      end

      context 'user is registered' do
        before { create(:alice, :on_cndt2020) }

        context 'user is admin' do
          let(:roles) { ['CNDT2020-Admin'] }

          context 'published' do
            before { create(:speaker_announcement, :published) }
            it 'has 公開済み announcement' do
              subject
              expect(response).to(be_successful)
              expect(response).to(have_http_status('200'))
              expect(response.body).to(include('alice'))
              expect(response.body).to(include('公開済み'))
              expect(response.body).to(include('test announcement for alice'))
            end

            context 'not published' do
              before { create(:speaker_announcement) }
              it 'has 非公開 announcement' do
                subject
                expect(response).to(be_successful)
                expect(response).to(have_http_status('200'))
                expect(response.body).to(include('alice'))
                expect(response.body).to(include('非公開'))
                expect(response.body).to(include('test announcement for alice'))
              end
            end
          end
        end

        context 'user is not admin' do
          it 'returns a failed response' do
            subject
            expect(response).to_not(be_successful)
            expect(response).to(have_http_status('403'))
          end
        end
      end
    end
  end
end
