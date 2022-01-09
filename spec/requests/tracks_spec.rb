require 'rails_helper'

RSpec.describe(TracksController, type: :request) do
  subject { get '/cndt2020/dashboard' }
  let!(:session) { { userinfo: { info: { email: 'alice@example.com', extra: { sub: 'aaa' } }, extra: { raw_info: { sub: 'aaa', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }

  describe 'GET /:event/dashboard' do
    describe 'logged in and registered' do
      before do
        create(:cndt2020)
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      context 'user is admin' do
        let(:roles) { ['CNDT2020-Admin'] }

        it 'return a success response' do
          subject
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
        end

        it 'link to admin is displayed' do
          subject
          expect(response.body).to(include('<a class="dropdown-item" href="/cndt2020/admin">管理画面</a>'))
        end

        context 'user is speaker' do
          let!(:alice) { create(:speaker_alice) }
          it 'show speaker' do
            subject
            expect(response).to(be_successful)
            expect(response.body).to(include('<h4>Alice様へのお知らせ</h4>'))
          end

          context 'wnen announcement is not published' do
            before do
              create(:speaker_announcement, speakers: [alice])
            end
            it 'not exists speaker_announcements' do
              subject
              expect(response).to(be_successful)
              expect(response.body).to(include('<h4>Alice様へのお知らせ</h4>'))
              expect(response.body).not_to(include('<p>test_announcement</p>'))
            end
          end

          context 'when announcement is published' do
            before do
              create(:speaker_announcement, :published, speakers: [alice])
              create(:speaker_announcement, :speaker_mike, speakers: [create(:speaker_mike)])
            end

            it "show only alice's announcements" do
              subject
              expect(response).to(be_successful)
              expect(response.body).to(include('<h4>Alice様へのお知らせ</h4>'))
              expect(response.body).to(include('<p>test announcement for alice</p>'))
              expect(response.body).not_to(include('<p>test announcement for mike</p>'))
              expect(SpeakerAnnouncement.where(publish: true).size).to(eq(2))
            end
          end
        end

        context 'user is not speaker' do
          it 'not show speaker_announcements' do
            subject
            expect(response).to(be_successful)
            expect(response.body).not_to(include('<h4>Alice様へのお知らせ</h4>'))
          end
        end
      end

      context 'user is not admin' do
        it 'return a success response' do
          subject
          expect(response).to(be_successful)
          expect(response).to(have_http_status('200'))
        end

        it 'link to admin is not displayed' do
          subject
          expect(response.body).to_not(include('<a class="dropdown-item" href="/admin">管理画面</a>'))
        end
      end

      context "get not exists event's dashboard" do
        it 'returns not found response' do
          get '/not_found/dashboard'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('404'))
        end
      end
    end

    describe 'not logged in' do
      before do
        create(:cndt2020)
      end

      context "get exists event's dashboard" do
        it 'redirect to top page a success response' do
          subject
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020'))
        end
      end

      context "get not exists event's dashboard" do
        it 'redirect to top page a success response' do
          get '/not_found/dashboard'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('404'))
        end
      end
    end
  end

  describe 'GET /:event/tracks' do
    describe 'logged in and registered' do
      before do
        create(:cndt2020, :opened)
        create(:alice, :on_cndt2020)
        allow_any_instance_of(ActionDispatch::Request).to(receive(:session).and_return(session))
      end

      context 'when user access to dashboard' do
        it 'return a success response' do
          get '/cndt2020/tracks'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020/ui/'))
        end
      end

      context 'when user access to root page' do
        it 'redirect to tracks' do
          get '/cndt2020'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020/dashboard'))
        end
      end
    end

    describe 'not logged in' do
      before do
        create(:cndt2020)
      end

      context "get exists event's dashboard" do
        it 'redirect to top page a success response' do
          get '/cndt2020/tracks'
          expect(response).to_not(be_successful)
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to('/cndt2020'))
        end
      end
    end
  end
end
