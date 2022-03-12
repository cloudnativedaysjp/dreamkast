require 'rails_helper'

RSpec.describe(TalksController, type: :controller) do
  describe 'video_archived?' do
    let!(:category) { create(:talk_category1, conference: conference) }
    let!(:difficulty) { create(:talk_difficulties1, conference: conference) }
    let!(:talk1) { create(:talk1, conference: conference) }

    shared_examples_for :video_archived_method_returns do |bool|
      it "video_archived? returns #{bool}" do
        controller = TalksController.new
        expect(controller.video_archived?(talk1)).to(bool ? be_truthy : be_falsey)
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_all_ok do |bool|
      context 'proposal_item whether_it_can_be_published is all_ok' do
        before do
          create(:proposal_item_configs_whether_it_can_be_published, :all_ok, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :all_ok, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :video_archived_method_returns, bool
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_only_slide do |bool|
      context 'proposal_item whether_it_can_be_published is only_slide' do
        before do
          create(:proposal_item_configs_whether_it_can_be_published, :only_slide, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :only_slide, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :video_archived_method_returns, bool
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_only_video do |bool|
      context 'proposal_item whether_it_can_be_published is only_video' do
        before do
          create(:proposal_item_configs_whether_it_can_be_published, :only_video, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :only_video, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :video_archived_method_returns, bool
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_all_ng do |bool|
      context 'proposal_item whether_it_can_be_published is all_ng' do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :all_ng, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :all_ng, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :video_archived_method_returns, bool
      end
    end

    shared_examples_for :video_is_published do |bool|
      context 'video is published' do
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :video_archived_method_returns, bool
      end
    end

    shared_examples_for :video_is_not_published do |bool|
      context "video isn't published" do
        let!(:talk1) { create(:talk1, :video_not_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :video_archived_method_returns, bool
      end
    end

    context 'conference is registered' do
      let!(:conference) { create(:cndt2020, :registered) }

      it_should_behave_like :video_is_published, true
      it_should_behave_like :video_is_not_published, false

      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
    end

    context 'conference is opened' do
      let!(:conference) { create(:cndt2020, :opened) }

      it_should_behave_like :video_is_published, true
      it_should_behave_like :video_is_not_published, false

      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
    end

    context 'conference is closed' do
      let!(:conference) { create(:cndt2020, :closed) }

      it_should_behave_like :video_is_published, true
      it_should_behave_like :video_is_not_published, false

      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
    end

    context 'conference is archived' do
      let!(:conference) { create(:cndt2020, :archived) }

      it_should_behave_like :video_is_published, true
      it_should_behave_like :video_is_not_published, false

      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
      it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
    end
  end
end
