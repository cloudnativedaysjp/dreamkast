# == Schema Information
#
# Table name: talks
#
#  id                    :bigint           not null, primary key
#  abstract              :text(65535)
#  acquired_seats        :integer          default(0), not null
#  document_url          :string(255)
#  end_offset            :integer          default(0), not null
#  end_time              :time
#  execution_phases      :json
#  expected_participants :json
#  movie_url             :string(255)
#  number_of_seats       :integer          default(0), not null
#  show_on_timetable     :boolean
#  start_offset          :integer          default(0), not null
#  start_time            :time
#  title                 :string(255)
#  video_published       :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  conference_day_id     :integer
#  conference_id         :integer
#  sponsor_id            :integer
#  talk_category_id      :bigint
#  talk_difficulty_id    :bigint
#  talk_time_id          :integer
#  track_id              :integer
#
# Indexes
#
#  index_talks_on_conference_id       (conference_id)
#  index_talks_on_talk_category_id    (talk_category_id)
#  index_talks_on_talk_difficulty_id  (talk_difficulty_id)
#  index_talks_on_track_id            (track_id)
#

require 'rails_helper'

describe Talk, type: :model do
  context 'update on_air status' do
    before do
      create(:cndt2020)
    end
    let!(:talk1) { create(:talk1, :accepted) }
    let!(:talk2) { create(:talk2, :accepted, :conference_day_id_1) }
    let!(:video1) { create(:video, :off_air) }
    let!(:video2) { create(:video, :on_air, :talk2) }
    context 'start streaming talk1' do
      before do
        talk1.start_streaming
      end

      it 'should be on_air' do
        expect(talk1.video.on_air).to(eq(true))
      end

      example 'talk in the same track and same conference_day should be off_air' do
        expect(talk2.video.on_air).to(eq(false))
      end
    end

    context 'stop streaming' do
      it 'should be off_air' do
        talk1.stop_streaming
        expect(talk1.video.on_air).to(eq(false))
      end
    end
  end

  context 'live?' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1) }
    let!(:proposal_item_config_1) { create(:proposal_item_configs_presentation_method, :live, conference: cndt2020) }
    let!(:proposal_item_config_2) { create(:proposal_item_configs_presentation_method, :video, conference: cndt2020) }

    context 'live session' do
      let!(:presentation_method) { create(:presentation_method, conference: cndt2020, talk:, params: proposal_item_config_1.id) }

      it 'should be true' do
        expect(talk.live?).to(be_truthy)
      end
    end

    context 'non-live session' do
      let!(:presentation_method) { create(:presentation_method, conference: cndt2020, talk:, params: proposal_item_config_2.id) }

      it 'should be true' do
        expect(talk.live?).to(be_falsey)
      end
    end
  end

  describe '#export_csv' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1) }
    let!(:proposal_item_config_1) { create(:proposal_item_configs_presentation_method, :live, conference: cndt2020) }
    let!(:proposal_item_config_2) { create(:proposal_item_configs_presentation_method, :video, conference: cndt2020) }
    let(:expected) {
      <<~EOS
        id,title,abstract,speaker,session_time,difficulty,category,created_at,additional_documents,twitter_id,company,start_to_end,sponsor_session,presentation_method,avatar_url,date,track_id
        1,talk1,あいうえおかきくけこさしすせそ,"",40,,,#{talk.created_at.strftime('%Y-%m-%d %H:%M:%S +0900')},"","","",12:00-12:40,No,,"",2020-09-08,A
      EOS
    }

    context 'has full attributes' do
      it 'export csv' do
        File.open("./#{Talk.export_csv(cndt2020, [talk])}.csv", 'r', encoding: 'UTF-8') do |file|
          expect(file.read).to(eq(expected))
        end
      end
    end

    context 'on registration term' do
      let!(:talk) { create(:has_no_conference_days) }
      let(:expected) {
        <<~EOS
          id,title,abstract,speaker,session_time,difficulty,category,created_at,additional_documents,twitter_id,company,start_to_end,sponsor_session,presentation_method,avatar_url,date,track_id
          100,not accepted talk,あいうえおかきくけこさしすせそ,"",40,,,#{talk.created_at.strftime('%Y-%m-%d %H:%M:%S +0900')},"","","","",No,,"",,
        EOS
      }
      it 'export csv without attributes will be decided later' do
        File.open("./#{Talk.export_csv(cndt2020, [talk])}.csv", 'r', encoding: 'UTF-8') do |file|
          expect(file.read).to(eq(expected))
        end
      end
    end
  end

  describe '#calendar' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1, :has_room) }
    it 'has full attributes' do
      expect(talk.calendar.summary).to(eq('talk1'))
      expect(talk.calendar.description.value).to(eq("
TrackA
会場: ONLINE
https://event.cloudnativedays.jp/cndt2020/talks/1

あいうえおかきくけこさしすせそ
"))
      expect(talk.calendar.dtstart.value).to(eq(DateTime.new(2020, 9, 8, 12)))
      expect(talk.calendar.dtend.value).to(eq(DateTime.new(2020, 9, 8, 12, 40)))
    end
  end

  describe 'Chat message' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1, :has_room) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:bob) { create(:bob, :on_cndt2020, conference: cndt2020) }
    context 'if talk has child messages' do
      before do
        create_list(:messages, 2, :alice, :roomid1, profile: alice)
        create_list(:messages, 2, :alice, :roomid1, :qa, profile: alice)
        create_list(:messages, 2, :alice, :roomid2, profile: alice)
      end
      it 'should return chat messages' do
        expect(talk.chat_messages.count).to(eq(4))
      end
      it 'should return qa messages only' do
        expect(talk.qa_messages.count).to(eq(2))
      end
    end
  end

  describe '#archived?' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1) }

    context 'talk is not finished' do
      around { |e| travel_to(Time.zone.local(2020, 9, 8, 12, 49)) { e.run } }

      it 'returns false' do
        expect(talk.archived?).to(be_falsey)
      end
    end

    context 'talk is finished' do
      around { |e| travel_to(Time.zone.local(2020, 9, 8, 13, 50)) { e.run } }

      it 'returns true' do
        expect(talk.archived?).to(be_truthy)
      end
    end
  end

  describe '#allowed_showing_video?' do
    before do
      create(:proposal_item_configs_whether_it_can_be_published, :all_ok, conference: cndt2020)
      create(:proposal_item_configs_whether_it_can_be_published, :only_video, conference: cndt2020)
      create(:proposal_item_configs_whether_it_can_be_published, :only_slide, conference: cndt2020)
      create(:proposal_item_configs_whether_it_can_be_published, :all_ng, conference: cndt2020)
    end

    let!(:cndt2020) { create(:cndt2020) }

    context 'all ok' do
      let!(:talk) { create(:talk1) }
      let!(:whether_it_can_be_published) { create(:proposal_item_whether_it_can_be_published, :all_ok, talk:) }

      it 'should be true' do
        expect(talk.allowed_showing_video?).to(be_truthy)
      end
    end

    context 'only video' do
      let!(:talk) { create(:talk1) }
      let!(:whether_it_can_be_published) { create(:proposal_item_whether_it_can_be_published, :only_video, talk:) }

      it 'should be true' do
        expect(talk.allowed_showing_video?).to(be_truthy)
      end
    end

    context 'only slide' do
      let!(:talk) { create(:talk1) }
      let!(:whether_it_can_be_published) { create(:proposal_item_whether_it_can_be_published, :only_slide, talk:) }

      it 'should be false' do
        expect(talk.allowed_showing_video?).to(be_falsey)
      end
    end

    context 'all_ng' do
      let!(:talk) { create(:talk1) }
      let!(:whether_it_can_be_published) { create(:proposal_item_whether_it_can_be_published, :all_ng, talk:) }

      it 'should be false' do
        expect(talk.allowed_showing_video?).to(be_falsey)
      end
    end
  end
end
