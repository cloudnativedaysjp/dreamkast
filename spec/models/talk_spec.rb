require 'rails_helper'

describe Talk, type: :model do
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

    context 'with preloaded proposal_items and config_cache' do
      let!(:presentation_method) { create(:presentation_method, conference: cndt2020, talk:, params: proposal_item_config_1.id) }
      let(:preloaded_talk) { Talk.includes(:proposal_items).find(talk.id) }
      let(:config_cache) { ProposalItemConfig.where(conference_id: cndt2020.id).index_by(&:id) }

      it 'returns true without issuing additional queries for proposal_items or ProposalItemConfig' do
        preloaded_talk
        config_cache
        expect(preloaded_talk.proposal_items).to(be_loaded)

        result = nil
        query_count = 0
        counter = ->(_name, _start, _finish, _id, payload) {
          query_count += 1 unless %w[SCHEMA TRANSACTION].include?(payload[:name])
        }
        ActiveSupport::Notifications.subscribed(counter, 'sql.active_record') do
          result = preloaded_talk.live?(config_cache:)
        end

        expect(result).to(be(true))
        expect(query_count).to(eq(0))
      end

      it 'uses the supplied cache instead of querying ProposalItemConfig' do
        expect(ProposalItemConfig).not_to(receive(:find))
        expect(preloaded_talk.live?(config_cache:)).to(be(true))
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


  describe '#ogp_image' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { create(:talk1) }

    context 'when ogp_image_url is present' do
      before do
        talk.update(ogp_image_url: 'https://example.com/custom-ogp.png')
      end

      it 'returns the custom ogp_image_url' do
        expect(talk.ogp_image).to(eq('https://example.com/custom-ogp.png'))
      end
    end

    context 'when ogp_image_url is blank and has speakers' do
      let!(:speaker) { create(:speaker_alice) }

      before do
        talk.speakers << speaker
      end

      it 'returns the first speaker avatar' do
        expect(talk.ogp_image).to(eq(speaker.avatar_or_dummy_url))
      end
    end

    context 'when ogp_image_url is blank and has no speakers' do
      it 'returns dummy.png' do
        expect(talk.ogp_image).to(eq('dummy.png'))
      end
    end
  end

  describe '文字数制限のバリデーション' do
    let!(:cndt2020) { create(:cndt2020) }
    let!(:talk) { build(:talk1, conference: cndt2020) }

    describe 'タイトルの文字数制限' do
      context 'タイトルが60文字の場合' do
        before do
          talk.title = 'あ' * 60
        end

        it 'バリデーションが通る' do
          expect(talk).to(be_valid)
        end
      end

      context 'タイトルが61文字の場合' do
        before do
          talk.title = 'あ' * 61
        end

        it 'バリデーションエラーになる' do
          expect(talk).not_to(be_valid)
          expect(talk.errors[:title]).to(include('は60文字以内で入力してください（現在61文字）'))
        end
      end

      context 'タイトルが半角60文字の場合' do
        before do
          talk.title = 'a' * 60
        end

        it 'バリデーションが通る' do
          expect(talk).to(be_valid)
        end
      end

      context 'タイトルが半角61文字の場合' do
        before do
          talk.title = 'a' * 61
        end

        it 'バリデーションエラーになる' do
          expect(talk).not_to(be_valid)
          expect(talk.errors[:title]).to(include('は60文字以内で入力してください（現在61文字）'))
        end
      end

      context 'タイトルが全角・半角混在で60文字の場合' do
        before do
          talk.title = 'あ' * 30 + 'a' * 30
        end

        it 'バリデーションが通る' do
          expect(talk).to(be_valid)
        end
      end

      context 'タイトルに絵文字が含まれる場合（絵文字1つで1文字としてカウント）' do
        context '絵文字59個 + 通常文字1文字 = 60文字の場合' do
          before do
            talk.title = '😀' * 59 + 'あ'
          end

          it 'バリデーションが通る' do
            expect(talk).to(be_valid)
          end
        end

        context '絵文字60個 = 60文字の場合' do
          before do
            talk.title = '😀' * 60
          end

          it 'バリデーションが通る' do
            expect(talk).to(be_valid)
          end
        end

        context '絵文字61個 = 61文字の場合' do
          before do
            talk.title = '😀' * 61
          end

          it 'バリデーションエラーになる' do
            expect(talk).not_to(be_valid)
            expect(talk.errors[:title]).to(include('は60文字以内で入力してください（現在61文字）'))
          end
        end

        context '複合絵文字（ゼロ幅結合子を含む）が含まれる場合' do
          before do
            # 👨‍👩‍👧‍👦 は複数のコードポイントで構成されるが、1文字としてカウントされるべき
            talk.title = '👨‍👩‍👧‍👦' * 30
          end

          it 'バリデーションが通る（30文字としてカウント）' do
            expect(talk).to(be_valid)
            expect(talk.title.each_grapheme_cluster.count).to(eq(30))
          end
        end

        context '絵文字と通常文字の混在で60文字の場合' do
          before do
            talk.title = '😀' * 30 + 'あ' * 30
          end

          it 'バリデーションが通る' do
            expect(talk).to(be_valid)
          end
        end
      end

      context 'タイトルが空の場合' do
        before do
          talk.title = ''
        end

        it 'presenceバリデーションでエラーになる' do
          expect(talk).not_to(be_valid)
          expect(talk.errors[:title]).not_to(be_empty)
        end
      end
    end

    describe '概要の文字数制限' do
      context '概要が500文字の場合' do
        before do
          talk.abstract = 'あ' * 500
        end

        it 'バリデーションが通る' do
          expect(talk).to(be_valid)
        end
      end

      context '概要が501文字の場合' do
        before do
          talk.abstract = 'あ' * 501
        end

        it 'バリデーションエラーになる' do
          expect(talk).not_to(be_valid)
          expect(talk.errors[:abstract]).to(include('は500文字以内で入力してください（現在501文字）'))
        end
      end

      context '概要が半角500文字の場合' do
        before do
          talk.abstract = 'a' * 500
        end

        it 'バリデーションが通る' do
          expect(talk).to(be_valid)
        end
      end

      context '概要が半角501文字の場合' do
        before do
          talk.abstract = 'a' * 501
        end

        it 'バリデーションエラーになる' do
          expect(talk).not_to(be_valid)
          expect(talk.errors[:abstract]).to(include('は500文字以内で入力してください（現在501文字）'))
        end
      end

      context '概要が全角・半角混在で500文字の場合' do
        before do
          talk.abstract = 'あ' * 250 + 'a' * 250
        end

        it 'バリデーションが通る' do
          expect(talk).to(be_valid)
        end
      end

      context '概要に絵文字が含まれる場合（絵文字1つで1文字としてカウント）' do
        context '絵文字499個 + 通常文字1文字 = 500文字の場合' do
          before do
            talk.abstract = '😀' * 499 + 'あ'
          end

          it 'バリデーションが通る' do
            expect(talk).to(be_valid)
          end
        end

        context '絵文字500個 = 500文字の場合' do
          before do
            talk.abstract = '😀' * 500
          end

          it 'バリデーションが通る' do
            expect(talk).to(be_valid)
          end
        end

        context '絵文字501個 = 501文字の場合' do
          before do
            talk.abstract = '😀' * 501
          end

          it 'バリデーションエラーになる' do
            expect(talk).not_to(be_valid)
            expect(talk.errors[:abstract]).to(include('は500文字以内で入力してください（現在501文字）'))
          end
        end

        context '複合絵文字（ゼロ幅結合子を含む）が含まれる場合' do
          before do
            # 👨‍👩‍👧‍👦 は複数のコードポイントで構成されるが、1文字としてカウントされるべき
            talk.abstract = '👨‍👩‍👧‍👦' * 250
          end

          it 'バリデーションが通る（250文字としてカウント）' do
            expect(talk).to(be_valid)
            expect(talk.abstract.each_grapheme_cluster.count).to(eq(250))
          end
        end

        context '絵文字と通常文字の混在で500文字の場合' do
          before do
            talk.abstract = '😀' * 250 + 'あ' * 250
          end

          it 'バリデーションが通る' do
            expect(talk).to(be_valid)
          end
        end
      end

      context '概要が空の場合' do
        before do
          talk.abstract = ''
        end

        it 'バリデーションが通る（概要は任意）' do
          expect(talk).to(be_valid)
        end
      end
    end
  end
end
