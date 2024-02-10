require 'rails_helper'

describe 'proposals/partial_show/proposal_result', type: :view do
  shared_examples_for :display_proposal_status do |status|
    it "display '#{status}'" do
      render partial: 'proposals/partial_show/proposal_result', locals: { talk: }
      expect(rendered).to(include("Proposal: (#{status})"))
    end
  end

  describe 'when cfp_result_visible is false' do
    let!(:cndt2020) { create(:cndt2020, :cfp_result_invisible) }
    let!(:talk) { create(:talk1, conference: cndt2020) }

    describe 'proposal is registered' do
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 0) }
      it_should_behave_like :display_proposal_status, 'エントリー済み'
    end

    describe 'proposal is accepted' do
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 1) }
      it_should_behave_like :display_proposal_status, 'エントリー済み'
    end

    describe 'proposal is rejected' do
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 2) }
      it_should_behave_like :display_proposal_status, 'エントリー済み'
    end

    describe 'talk is sponsor session' do
      let!(:sponsor) { create(:sponsor, conference: cndt2020) }
      let!(:talk) { create(:talk1, conference: cndt2020, sponsor:) }
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 0) }

      it 'not display proposal result' do
        render partial: 'proposals/partial_show/proposal_result', locals: { talk: }
        expect(rendered).to_not(include('Proposal: '))
      end
    end
  end

  describe 'when cfp_result_visible is true' do
    let!(:cndt2020) { create(:cndt2020, :cfp_result_visible) }
    let!(:talk) { create(:talk1, conference: cndt2020) }

    describe 'proposal is registered' do
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 0) }
      it_should_behave_like :display_proposal_status, 'エントリー済み'
    end

    describe 'proposal is accepted' do
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 1) }
      it_should_behave_like :display_proposal_status, '採択'
    end

    describe 'proposal is rejected' do
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 2) }
      it_should_behave_like :display_proposal_status, '不採択'
    end

    describe 'talk is sponsor session' do
      let!(:sponsor) { create(:sponsor, conference: cndt2020) }
      let!(:talk) { create(:talk1, conference: cndt2020, sponsor:) }
      let!(:proposal) { create(:proposal, conference: cndt2020, talk:, status: 0) }

      it 'not display proposal result' do
        render partial: 'proposals/partial_show/proposal_result', locals: { talk: }
        expect(rendered).to_not(include('Proposal: '))
      end
    end
  end
end
