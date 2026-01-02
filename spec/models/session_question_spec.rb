require 'rails_helper'

RSpec.describe SessionQuestion, type: :model do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:public_profile) { create(:public_profile, profile:, nickname: 'アリス') }

  describe 'validations' do
    describe 'body' do
      context 'when body is present' do
        let(:question) { build(:session_question, talk:, conference:, profile:, body: '質問内容') }

        it 'is valid' do
          expect(question).to be_valid
        end
      end

      context 'when body is blank' do
        let(:question) { build(:session_question, talk:, conference:, profile:, body: '') }

        it 'is invalid' do
          expect(question).not_to be_valid
          expect(question.errors[:body]).to include("can't be blank")
        end
      end

      context 'when body is nil' do
        let(:question) { build(:session_question, talk:, conference:, profile:, body: nil) }

        it 'is invalid' do
          expect(question).not_to be_valid
          expect(question.errors[:body]).to include("can't be blank")
        end
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:talk) }
    it { is_expected.to belong_to(:conference) }
    it { is_expected.to belong_to(:profile) }
    it { is_expected.to have_many(:session_question_answers).dependent(:destroy) }
    it { is_expected.to have_many(:session_question_votes).dependent(:destroy) }
  end

  describe 'scopes' do
    describe '.for_talk' do
      let!(:question1) { create(:session_question, talk:, conference:, profile:) }
      let!(:other_talk) { create(:talk2, conference:) }
      let!(:question2) { create(:session_question, talk: other_talk, conference:, profile:) }

      it 'returns questions for the specified talk' do
        expect(SessionQuestion.for_talk(talk.id)).to include(question1)
        expect(SessionQuestion.for_talk(talk.id)).not_to include(question2)
      end
    end

    describe '.order_by_votes' do
      let!(:question1) { create(:session_question, talk:, conference:, profile:, votes_count: 5) }
      let!(:question2) { create(:session_question, talk:, conference:, profile:, votes_count: 10) }
      let!(:question3) { create(:session_question, talk:, conference:, profile:, votes_count: 5) }

      it 'orders by votes_count desc, then created_at desc' do
        ordered = SessionQuestion.order_by_votes
        expect(ordered.first).to eq(question2)
        # 同じ投票数の場合は新しい順
        expect(ordered[1..2]).to include(question1, question3)
      end
    end

    describe '.order_by_time' do
      let!(:question1) { create(:session_question, talk:, conference:, profile:) }
      let!(:question2) { create(:session_question, talk:, conference:, profile:) }
      let!(:question3) { create(:session_question, talk:, conference:, profile:) }

      it 'orders by created_at desc' do
        ordered = SessionQuestion.order_by_time
        expect(ordered.first).to eq(question3)
        expect(ordered.last).to eq(question1)
      end
    end

    describe '.visible' do
      let!(:visible_question) { create(:session_question, talk:, conference:, profile:, hidden: false) }
      let!(:hidden_question) { create(:session_question, :hidden, talk:, conference:, profile:) }

      it 'returns only visible questions' do
        expect(SessionQuestion.visible).to include(visible_question)
        expect(SessionQuestion.visible).not_to include(hidden_question)
      end
    end

    describe '.hidden' do
      let!(:visible_question) { create(:session_question, talk:, conference:, profile:, hidden: false) }
      let!(:hidden_question) { create(:session_question, :hidden, talk:, conference:, profile:) }

      it 'returns only hidden questions' do
        expect(SessionQuestion.hidden).to include(hidden_question)
        expect(SessionQuestion.hidden).not_to include(visible_question)
      end
    end
  end

  describe '#update_votes_count!' do
    let(:question) { create(:session_question, talk:, conference:, profile:) }

    context 'when votes exist' do
      before do
        create_list(:session_question_vote, 3, session_question: question)
      end

      it 'updates votes_count correctly' do
        expect { question.update_votes_count! }.to change { question.reload.votes_count }.from(0).to(3)
      end
    end

    context 'when no votes exist' do
      it 'sets votes_count to 0' do
        question.update_column(:votes_count, 5)
        question.update_votes_count!
        expect(question.reload.votes_count).to eq(0)
      end
    end

    context 'when an error occurs' do
      before do
        allow(question).to receive(:session_question_votes).and_raise(StandardError.new('Database error'))
      end

      it 'raises the error' do
        expect { question.update_votes_count! }.to raise_error(StandardError, 'Database error')
      end
    end
  end
end
