require 'rails_helper'

describe Admin::SpeakerAnnouncementsController, type: :request do
  let!(:session) { { userinfo: { info: { email: 'alice@example.com' }, extra: { raw_info: { sub: 'google-oauth2|alice', 'https://cloudnativedays.jp/roles' => roles } } } } }
  let(:roles) { [] }
  let!(:conference) { create(:cndt2020) }

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

  describe 'GET :event/admin/speaker_announcements#index' do
    subject { get(admin_speaker_announcements_path(event: 'cndt2020')) }
    context "user doesn't logged in" do
      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_return(nil))
      end

      it 'redirect to login page' do
        subject
        expect(response).to_not(be_successful)
        expect(response).to(have_http_status('302'))
        expect(response).to(redirect_to('/auth/login?origin=/cndt2020/admin/speaker_announcements'))
      end
    end

    context 'user logged in' do
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

  describe 'POST :event/admin/speaker_announcements#create' do
    let(:roles) { ['CNDT2020-Admin'] }
    let(:alice) { create(:alice, :on_cndt2020) }
    let!(:speaker_accepted) { create(:speaker_alice, :with_talk1_accepted) }
    let!(:speaker_rejected) { create(:speaker_bob, :with_talk2_rejected) }

    before do
      create(:alice, :on_cndt2020)
      mailer = double('mailer')
      allow(mailer).to(receive(:deliver_later))
      allow(SpeakerMailer).to(receive(:inform_speaker_announcement).and_return(mailer))
    end

    context 'when speaker_id are specified' do
      let(:params) do
        {
          event: 'cndt2020',
          speaker_announcement: {
            publish_time: Time.now,
            body: 'Test announcement body',
            publish: publish_flag,
            speaker_ids: [speaker_accepted.id],
            receiver: 'person'
          }
        }
      end

      context 'when creating a published announcement' do
        let(:publish_flag) { true }

        it 'sends an email to the speaker specified' do
          post admin_speaker_announcements_path(params)

          expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
        end

        it 'does not send an email to the speaker not specified' do
          post admin_speaker_announcements_path(params)

          expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
        end
      end

      context 'when creating an unpublished announcement' do
        let(:publish_flag) { false }

        it 'does not send an email to the speaker' do
          post admin_speaker_announcements_path(params)

          expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement))
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
        end
      end
    end

    context 'when speaker_id are not specified' do
      context 'all speakers are selected' do
        let(:params) do
          {
            event: 'cndt2020',
            speaker_announcement: {
              publish_time: Time.now,
              body: 'Test announcement body',
              publish: publish_flag,
              speaker_ids: [],
              receiver: 'all_speaker'
            }
          }
        end

        context 'when creating a published announcement' do
          let(:publish_flag) { true }

          it 'sends an email to the speaker accepted' do
            post admin_speaker_announcements_path(params)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end

          it 'does not send an email to the speaker rejected' do
            post admin_speaker_announcements_path(params)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end
        end
      end

      context 'only_accepted are selected' do
        let(:params) do
          {
            event: 'cndt2020',
            speaker_announcement: {
              publish_time: Time.now,
              body: 'Test announcement body',
              publish: publish_flag,
              speaker_ids: [],
              receiver: 'only_accepted'
            }
          }
        end

        context 'when creating a published announcement' do
          let(:publish_flag) { true }

          it 'sends an email to the speaker accepted' do
            post admin_speaker_announcements_path(params)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end

          it 'does not send an email to the speaker rejected' do
            post admin_speaker_announcements_path(params)

            expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end
        end
      end

      context 'only_rejected are selected' do
        let(:params) do
          {
            event: 'cndt2020',
            speaker_announcement: {
              publish_time: Time.now,
              body: 'Test announcement body',
              publish: publish_flag,
              speaker_ids: [],
              receiver: 'only_rejected'
            }
          }
        end

        context 'when creating a published announcement' do
          let(:publish_flag) { true }

          it 'does not sends an email to the speaker accepted' do
            post admin_speaker_announcements_path(params)

            expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end

          it 'send an email to the speaker rejected' do
            post admin_speaker_announcements_path(params)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end
        end
      end
    end
  end


  describe 'PUT :event/admin/speaker_announcements#update' do
    let(:roles) { ['CNDT2020-Admin'] }
    let(:alice) { create(:alice, :on_cndt2020) }
    let!(:speaker_accepted) { create(:speaker_alice, :with_talk1_accepted) }
    let!(:speaker_rejected) { create(:speaker_bob, :with_talk2_rejected) }

    before do
      create(:alice, :on_cndt2020)
      mailer = double('mailer')
      allow(mailer).to(receive(:deliver_later))
      allow(SpeakerMailer).to(receive(:inform_speaker_announcement).and_return(mailer))
    end

    context 'when speaker_id are specified' do
      let!(:speaker_announcement) { create(:speaker_announcement) }
      let!(:params) do
        {
          event: 'cndt2020',
          speaker_announcement: {
            publish_time: Time.now,
            body: 'Updated Test announcement body',
            publish: publish_flag,
            speaker_ids: [speaker_accepted.id],
            receiver: 'person'
          }
        }
      end

      context 'when creating a published announcement' do
        let(:publish_flag) { true }

        it 'sends an email to the speaker specified' do
          put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

          expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
        end

        it 'does not send an email to the speaker not specified' do
          put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

          expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
        end
      end

      context 'when creating an unpublished announcement' do
        let(:publish_flag) { false }

        it 'does not send an email to the speaker' do
          put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

          expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement))
          expect(response).to(have_http_status('302'))
          expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
        end
      end
    end

    context 'when speaker_id are not specified' do
      context 'all speakers are selected' do
        let!(:speaker_announcement) { create(:speaker_announcement, :published_all, publish: false) }
        let!(:params) do
          {
            event: 'cndt2020',
            speaker_announcement: {
              publish_time: Time.now,
              body: 'Test announcement body',
              publish: publish_flag,
              speaker_ids: [],
              receiver: 'all_speaker'
            }
          }
        end

        context 'when creating a published announcement' do
          let(:publish_flag) { true }

          it 'sends an email to the speaker accepted' do
            put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end

          it 'does not send an email to the speaker rejected' do
            put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end
        end
      end

      context 'only_accepted are selected' do
        let!(:speaker_announcement) { create(:speaker_announcement, :only_accepted, publish: false) }
        let!(:params) do
          {
            event: 'cndt2020',
            speaker_announcement: {
              publish_time: Time.now,
              body: 'Test announcement body',
              publish: publish_flag,
              speaker_ids: [],
              receiver: 'only_accepted'
            }
          }
        end

        context 'when creating a published announcement' do
          let(:publish_flag) { true }

          it 'sends an email to the speaker accepted' do
            put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end

          it 'does not send an email to the speaker rejected' do
            put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

            expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end
        end
      end

      context 'only_rejected are selected' do
        let!(:speaker_announcement) { create(:speaker_announcement, :only_rejected, publish: false) }
        let!(:params) do
          {
            event: 'cndt2020',
            speaker_announcement: {
              publish_time: Time.now,
              body: 'Test announcement body',
              publish: publish_flag,
              speaker_ids: [],
              receiver: 'only_rejected'
            }
          }
        end

        context 'when creating a published announcement' do
          let(:publish_flag) { true }

          it 'does not sends an email to the speaker accepted' do
            put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

            expect(SpeakerMailer).not_to(have_received(:inform_speaker_announcement).with(conference, speaker_accepted))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end

          it 'send an email to the speaker rejected' do
            put admin_speaker_announcement_path(event: conference.abbr, id: speaker_announcement.id, params:)

            expect(SpeakerMailer).to(have_received(:inform_speaker_announcement).with(conference, speaker_rejected))
            expect(response).to(have_http_status('302'))
            expect(response).to(redirect_to(admin_speaker_announcements_path(event: 'cndt2020')))
          end
        end
      end
    end
  end
end
