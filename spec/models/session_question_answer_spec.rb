require 'rails_helper'

RSpec.describe SessionQuestionAnswer, type: :model do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:speaker) { create(:speaker_alice, conference:) }
  let!(:question) { create(:session_question, talk:, conference:, profile:) }

  describe 'validations' do
    describe 'body' do
      context 'when body is present' do
        let(:answer) { build(:session_question_answer, session_question: question, speaker:, conference:, body: '回答内容') }

        it 'is valid' do
          expect(answer).to be_valid
        end
      end

      context 'when body is blank' do
        let(:answer) { build(:session_question_answer, session_question: question, speaker:, conference:, body: '') }

        it 'is invalid' do
          expect(answer).not_to be_valid
          expect(answer.errors[:body]).to include("can't be blank")
        end
      end

      context 'when body is nil' do
        let(:answer) { build(:session_question_answer, session_question: question, speaker:, conference:, body: nil) }

        it 'is invalid' do
          expect(answer).not_to be_valid
          expect(answer.errors[:body]).to include("can't be blank")
        end
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:session_question) }
    it { is_expected.to belong_to(:speaker) }
    it { is_expected.to belong_to(:conference) }
  end

  describe 'scopes' do
    describe '.for_question' do
      let!(:answer1) { create(:session_question_answer, session_question: question, speaker:, conference:) }
      let!(:other_question) { create(:session_question, talk:, conference:, profile:) }
      let!(:answer2) { create(:session_question_answer, session_question: other_question, speaker:, conference:) }

      it 'returns answers for the specified question' do
        expect(SessionQuestionAnswer.for_question(question.id)).to include(answer1)
        expect(SessionQuestionAnswer.for_question(question.id)).not_to include(answer2)
      end
    end

    describe '.order_by_time' do
      let!(:answer1) { create(:session_question_answer, session_question: question, speaker:, conference:) }
      let!(:answer2) { create(:session_question_answer, session_question: question, speaker:, conference:) }
      let!(:answer3) { create(:session_question_answer, session_question: question, speaker:, conference:) }

      it 'orders by created_at asc' do
        ordered = SessionQuestionAnswer.order_by_time
        expect(ordered.first).to eq(answer1)
        expect(ordered.last).to eq(answer3)
      end
    end
  end
end
