require "rails_helper"

RSpec.describe(TalksController, type: :controller) do
  describe "display_video?" do
    let!(:category) { create(:talk_category1, conference: conference) }
    let!(:difficulty) { create(:talk_difficulties1, conference: conference) }
    let!(:talk1) { create(:talk1, conference: conference) }

    shared_examples_for :return_true_when_proposal_item_whether_it_can_be_published_is_all_ok do
      context "proposal_item whether_it_can_be_published is all_ok" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :all_ok, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :all_ok, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :return_true
      end
    end

    shared_examples_for :return_false_when_proposal_item_whether_it_can_be_published_is_only_slide do
      context "proposal_item whether_it_can_be_published is only_slide" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :only_slide, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :only_slide, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :return_false
      end
    end

    shared_examples_for :return_true_when_proposal_item_whether_it_can_be_published_is_only_video do
      context "proposal_item whether_it_can_be_published is only_video" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :only_video, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :only_video, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :return_true
      end
    end

    shared_examples_for :return_false_when_proposal_item_whether_it_can_be_published_is_all_ng do
      context "proposal_item whether_it_can_be_published is all_ng" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
          create(:proposal_item_configs_whether_it_can_be_published, :all_ng, conference: conference)
          create(:proposal_item_whether_it_can_be_published, :all_ng, talk: talk1)
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :return_false
      end
    end

    shared_examples_for :return_true_when_video_is_published_and_present_and_archived do
      context "talk is video_published, video is present and talk is archived" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :return_true
      end
    end

    shared_examples_for :return_false_when_video_is_not_published do
      context "video isn't published" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
        end
        let!(:talk1) { create(:talk1, :video_not_published, conference: conference) }
        let!(:video) { create(:video) }

        it_should_behave_like :return_false
      end
    end

    shared_examples_for :return_false_when_video_is_not_present do
      context "video isn't present" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(true))
        end
        let!(:talk1) { create(:talk1, :video_not_published, conference: conference) }

        it_should_behave_like :return_false
      end
    end

    shared_examples_for :return_false_video_is_not_archived do
      context "talk isn't archived" do
        before do
          allow_any_instance_of(Talk).to(receive(:archived?).and_return(false))
        end
        let!(:talk1) { create(:talk1, :video_published, conference: conference) }

        it_should_behave_like :return_false
      end
    end

    shared_examples_for :return_true do
      it "returns true" do
        controller = TalksController.new
        expect(controller.display_video?(talk1)).to(be_truthy)
      end
    end

    shared_examples_for :return_false do
      it "returns false" do
        controller = TalksController.new
        expect(controller.display_video?(talk1)).to(be_falsey)
      end
    end

    context "user logged in" do
      before do
        allow_any_instance_of(TalksController).to(receive(:logged_in?).and_return(true))
      end

      context "conference is registered" do
        let!(:conference) { create(:cndt2020, :registered) }

        it_should_behave_like :return_false
      end

      context "conference is opened" do
        let!(:conference) { create(:cndt2020, :opened) }

        it_should_behave_like :return_true_when_video_is_published_and_present_and_archived
        it_should_behave_like :return_false_when_video_is_not_published
        it_should_behave_like :return_false_when_video_is_not_present
        it_should_behave_like :return_false_video_is_not_archived

        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_all_ok
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_only_slide
        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_only_video
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_all_ng
      end

      context "conference is closed" do
        let!(:conference) { create(:cndt2020, :closed) }

        it_should_behave_like :return_true_when_video_is_published_and_present_and_archived
        it_should_behave_like :return_false_when_video_is_not_published
        it_should_behave_like :return_false_when_video_is_not_present
        it_should_behave_like :return_false_video_is_not_archived

        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_all_ok
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_only_slide
        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_only_video
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_all_ng
      end

      context "conference is archived" do
        let!(:conference) { create(:cndt2020, :archived) }

        it_should_behave_like :return_true_when_video_is_published_and_present_and_archived
        it_should_behave_like :return_false_when_video_is_not_published
        it_should_behave_like :return_false_when_video_is_not_present
        it_should_behave_like :return_false_video_is_not_archived

        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_all_ok
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_only_slide
        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_only_video
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_all_ng
      end
    end

    context "user doesn't logged in" do
      before do
        allow_any_instance_of(TalksController).to(receive(:logged_in?).and_return(false))
      end

      context "conference is registered" do
        let!(:conference) { create(:cndt2020, :registered) }

        it_should_behave_like :return_false
      end

      context "conference is opened" do
        let!(:conference) { create(:cndt2020, :opened) }

        it_should_behave_like :return_false
      end

      context "conference is closed" do
        let!(:conference) { create(:cndt2020, :closed) }

        it_should_behave_like :return_false
      end

      context "conference is archived" do
        let!(:conference) { create(:cndt2020, :archived) }

        it_should_behave_like :return_true_when_video_is_published_and_present_and_archived
        it_should_behave_like :return_false_when_video_is_not_published
        it_should_behave_like :return_false_when_video_is_not_present
        it_should_behave_like :return_false_video_is_not_archived

        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_all_ok
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_only_slide
        it_should_behave_like :return_true_when_proposal_item_whether_it_can_be_published_is_only_video
        it_should_behave_like :return_false_when_proposal_item_whether_it_can_be_published_is_all_ng
      end
    end
  end
end
