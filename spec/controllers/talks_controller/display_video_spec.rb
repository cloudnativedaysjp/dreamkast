require "rails_helper"

RSpec.describe(TalksController, type: :controller) do
  describe "display_video?" do
    let!(:category) { create(:talk_category1, conference: conference) }
    let!(:difficulty) { create(:talk_difficulties1, conference: conference) }
    let!(:talk1) { create(:talk1, conference: conference) }

    shared_examples_for :display_video_method_returns do |bool|
      it "display_video? returns #{bool}" do
        controller = TalksController.new
        expect(controller.display_video?(talk1)).to(bool ? be_truthy : be_falsey)
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_all_ok do |bool|
      context "proposal_item whether_it_can_be_published is all_ok" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :all_ok, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :all_ok, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_only_slide do |bool|
      context "proposal_item whether_it_can_be_published is only_slide" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :only_slide, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :only_slide, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_only_video do |bool|
      context "proposal_item whether_it_can_be_published is only_video" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :only_video, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :only_video, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    shared_examples_for :proposal_item_whether_it_can_be_published_is_all_ng do |bool|
      context "proposal_item whether_it_can_be_published is all_ng" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :all_ng, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :all_ng, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    shared_examples_for :video_is_published_and_present_and_archived do |bool|
      context "talk is video_published, video is present and talk is archived" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    shared_examples_for :video_is_not_published do |bool|
      context "video isn't published" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
        end
        let!(:talk1) { create(:talk1, :video_not_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    shared_examples_for :video_is_not_present do |bool|
      context "video isn't present" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
        end
        let!(:talk1) { create(:talk1, :video_not_published, conference: conference) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    shared_examples_for :video_is_not_archived do |bool|
      context "talk isn't archived" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }

        it_should_behave_like :display_video_method_returns, bool
      end
    end

    context "user logged in" do
      before do
        allow_any_instance_of(TalksController).to(receive(:logged_in?).and_return(true))
      end

      context "conference is registered" do
        let!(:conference) { create(:cndt2020, :registered) }

        it_should_behave_like :video_is_published_and_present_and_archived, false
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end

      context "conference is opened" do
        let!(:conference) { create(:cndt2020, :opened) }

        it_should_behave_like :video_is_published_and_present_and_archived, true
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end

      context "conference is closed" do
        let!(:conference) { create(:cndt2020, :closed) }

        it_should_behave_like :video_is_published_and_present_and_archived, true
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end

      context "conference is archived" do
        let!(:conference) { create(:cndt2020, :archived) }

        it_should_behave_like :video_is_published_and_present_and_archived, true
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end
    end

    context "user doesn't logged in" do
      before do
        allow_any_instance_of(TalksController).to(receive(:logged_in?).and_return(false))
      end

      context "conference is registered" do
        let!(:conference) { create(:cndt2020, :registered) }

        it_should_behave_like :video_is_published_and_present_and_archived, false
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end

      context "conference is opened" do
        let!(:conference) { create(:cndt2020, :opened) }

        it_should_behave_like :video_is_published_and_present_and_archived, false
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end

      context "conference is closed" do
        let!(:conference) { create(:cndt2020, :closed) }

        it_should_behave_like :video_is_published_and_present_and_archived, false
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end

      context "conference is archived" do
        let!(:conference) { create(:cndt2020, :archived) }

        it_should_behave_like :video_is_published_and_present_and_archived, true
        it_should_behave_like :video_is_not_published, false
        it_should_behave_like :video_is_not_present, false
        it_should_behave_like :video_is_not_archived, false

        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ok, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_slide, false
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_only_video, true
        it_should_behave_like :proposal_item_whether_it_can_be_published_is_all_ng, false
      end
    end
  end
end
