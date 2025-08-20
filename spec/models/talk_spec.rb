require 'rails_helper'

describe Talk, type: :model do
  describe 'session attributes' do
    let!(:cndt2020) { create(:cndt2020) }
    let(:talk) { create(:talk1) }
    let(:keynote_attr) { create(:session_attribute, name: 'keynote', is_exclusive: false) }
    let(:sponsor_attr) { create(:session_attribute, name: 'sponsor', is_exclusive: false) }
    let(:intermission_attr) { create(:session_attribute, name: 'intermission', is_exclusive: true) }

    describe 'associations' do
      it 'has many talk_talk_attributes' do
        association = Talk.reflect_on_association(:talk_talk_attributes)
        expect(association.macro).to(eq(:has_many))
        expect(association.options[:dependent]).to(eq(:destroy))
      end

      it 'has many talk_attributes through talk_talk_attributes' do
        association = Talk.reflect_on_association(:talk_attributes)
        expect(association.macro).to(eq(:has_many))
        expect(association.options[:through]).to(eq(:talk_talk_attributes))
      end
    end

    describe '#keynote?' do
      it 'returns true when keynote attribute is assigned' do
        talk.talk_attributes << keynote_attr
        expect(talk.keynote?).to(be(true))
      end

      it 'returns false when keynote attribute is not assigned' do
        expect(talk.keynote?).to(be(false))
      end
    end

    describe '#sponsor_session?' do
      it 'returns true when sponsor attribute is assigned' do
        talk.talk_attributes << sponsor_attr
        expect(talk.sponsor_session?).to(be(true))
      end

      it 'returns true when sponsor is present (backward compatibility)' do
        sponsor = create(:sponsor)
        talk.update!(sponsor:)
        expect(talk.sponsor_session?).to(be(true))
      end

      it 'returns false when neither sponsor attribute nor sponsor is present' do
        expect(talk.sponsor_session?).to(be(false))
      end
    end

    describe '#intermission?' do
      it 'returns true when intermission attribute is assigned' do
        talk.talk_attributes << intermission_attr
        expect(talk.intermission?).to(be(true))
      end

      it 'returns true when abstract is intermission (backward compatibility)' do
        talk.update!(abstract: 'intermission')
        expect(talk.intermission?).to(be(true))
      end

      it 'returns false when neither intermission attribute nor abstract=intermission' do
        expect(talk.intermission?).to(be(false))
      end
    end

    describe '#sponsor_keynote?' do
      it 'returns true when both sponsor and keynote attributes are assigned' do
        talk.talk_attributes << [sponsor_attr, keynote_attr]
        expect(talk.sponsor_keynote?).to(be(true))
      end

      it 'returns false when only one attribute is present' do
        talk.talk_attributes << keynote_attr
        expect(talk.sponsor_keynote?).to(be(false))
      end
    end

    describe '#set_talk_attributes' do
      it 'sets session attributes from array of names' do
        # Ensure the attributes exist
        keynote_attr
        sponsor_attr

        talk.set_talk_attributes(['keynote', 'sponsor'])

        expect(talk.keynote?).to(be(true))
        expect(talk.sponsor_session?).to(be(true))
      end

      it 'replaces existing attributes' do
        # Ensure the attributes exist
        keynote_attr
        sponsor_attr

        talk.talk_attributes << keynote_attr
        expect(talk.keynote?).to(be(true))

        talk.set_talk_attributes(['sponsor'])

        expect(talk.keynote?).to(be(false))
        expect(talk.sponsor_session?).to(be(true))
      end
    end

    describe '#session_attribute_names' do
      it 'returns array of assigned attribute names' do
        talk.talk_attributes << [keynote_attr, sponsor_attr]

        expect(talk.session_attribute_names).to(match_array(['keynote', 'sponsor']))
      end

      it 'returns empty array when no attributes assigned' do
        expect(talk.session_attribute_names).to(eq([]))
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
        File.open(Talk.export_csv(cndt2020, [talk]), 'r', encoding: 'UTF-8') do |file|
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
        File.open(Talk.export_csv(cndt2020, [talk]), 'r', encoding: 'UTF-8') do |file|
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

  describe '#offline_participation_size' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:bob) { create(:bob, :on_cndt2020, :offline, conference: cndt2020) }

    context 'only online' do
      before do
        create(:registered_talk, talk:, profile: alice)
      end

      it 'return 0' do
        expect(talk.offline_participation_size).to(eq(0))
      end
    end

    context 'has one offline registration' do
      before do
        create(:registered_talk, talk:, profile: alice)
        create(:registered_talk, talk:, profile: bob)
      end
      it 'return 1' do
        expect(talk.offline_participation_size).to(eq(1))
      end
    end
  end

  describe '#online_participation_size' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1) }
    let!(:alice) { create(:alice, :on_cndt2020, conference: cndt2020) }
    let!(:bob) { create(:bob, :on_cndt2020, :offline, conference: cndt2020) }

    context 'only offline' do
      before do
        create(:registered_talk, talk:, profile: bob)
      end

      it 'return 0' do
        expect(talk.online_participation_size).to(eq(0))
      end
    end

    context 'has one online registration' do
      before do
        create(:registered_talk, talk:, profile: alice)
        create(:registered_talk, talk:, profile: bob)
      end
      it 'return 1' do
        expect(talk.online_participation_size).to(eq(1))
      end
    end
  end
end
