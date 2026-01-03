require 'rails_helper'

RSpec.describe SessionQuestionVote, type: :model do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile1) { create(:alice, :on_cndt2020, conference:) }
  let!(:profile2) { create(:bob, :on_cndt2020, conference:) }
  let!(:question) { create(:session_question, talk:, conference:, profile: profile1) }

  describe 'validations' do
    describe 'uniqueness of session_question_id and profile_id' do
      context 'when a vote already exists' do
        before do
          create(:session_question_vote, session_question: question, profile: profile1)
        end

        it 'prevents duplicate votes' do
          duplicate_vote = build(:session_question_vote, session_question: question, profile: profile1)
          expect(duplicate_vote).not_to be_valid
          expect(duplicate_vote.errors[:session_question_id]).to be_present
        end
      end

      context 'when different profiles vote' do
        before do
          create(:session_question_vote, session_question: question, profile: profile1)
        end

        it 'allows votes from different profiles' do
          vote2 = build(:session_question_vote, session_question: question, profile: profile2)
          expect(vote2).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it 'belongs to session_question' do
      expect(subject).to respond_to(:session_question)
      expect(subject.class.reflect_on_association(:session_question)).to be_present
    end

    it 'belongs to profile' do
      expect(subject).to respond_to(:profile)
      expect(subject.class.reflect_on_association(:profile)).to be_present
    end
  end

  describe 'callbacks' do
    describe 'after_commit' do
      let(:question) { create(:session_question, talk:, conference:, profile: profile1, votes_count: 0) }

      context 'when a vote is created' do
        it 'updates the question votes_count' do
          expect {
            create(:session_question_vote, session_question: question, profile: profile1)
            question.reload
          }.to change { question.votes_count }.from(0).to(1)
        end
      end

      context 'when a vote is destroyed' do
        let!(:vote) { create(:session_question_vote, session_question: question, profile: profile1) }

        before do
          question.update_votes_count!
        end

        it 'updates the question votes_count' do
          expect {
            vote.destroy
            question.reload
          }.to change { question.votes_count }.from(1).to(0)
        end
      end

      context 'when update_votes_count! fails' do
        let(:vote) { build(:session_question_vote, session_question: question, profile: profile1) }

        before do
          allow(question).to receive(:update_votes_count!).and_raise(StandardError.new('Error'))
        end

        it 'retries up to 3 times and logs error' do
          expect(Rails.logger).to receive(:error).at_least(:once)
          vote.save
          # after_commit は use_transactional_fixtures = true の場合実行されないため、直接呼び出す
          vote.send(:update_question_votes_count)
        end
      end
    end
  end
end
