require 'rails_helper'

RSpec.describe SessionQuestion, type: :model do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:profile2) { create(:bob, :on_cndt2020, conference:) }
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
          expect(question.errors[:body]).to include('を入力してください')
        end
      end

      context 'when body is nil' do
        let(:question) { build(:session_question, talk:, conference:, profile:, body: nil) }

        it 'is invalid' do
          expect(question).not_to be_valid
          expect(question.errors[:body]).to include('を入力してください')
        end
      end
    end
  end

  describe 'associations' do
    it 'belongs to talk' do
      expect(subject).to respond_to(:talk)
      expect(subject.class.reflect_on_association(:talk)).to be_present
    end

    it 'belongs to conference' do
      expect(subject).to respond_to(:conference)
      expect(subject.class.reflect_on_association(:conference)).to be_present
    end

    it 'belongs to profile' do
      expect(subject).to respond_to(:profile)
      expect(subject.class.reflect_on_association(:profile)).to be_present
    end

    it 'has many session_question_answers' do
      expect(subject).to respond_to(:session_question_answers)
      association = subject.class.reflect_on_association(:session_question_answers)
      expect(association).to be_present
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many session_question_votes' do
      expect(subject).to respond_to(:session_question_votes)
      association = subject.class.reflect_on_association(:session_question_votes)
      expect(association).to be_present
      expect(association.options[:dependent]).to eq(:destroy)
    end
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
      let!(:profile3) do
        user = FactoryBot.create(:user, sub: "google-oauth2|charlie-#{SecureRandom.hex(8)}", email: "charlie-#{SecureRandom.hex(8)}@example.com")
        Profile.create!(
          user_id: user.id,
          last_name: 'charlie',
          first_name: 'Charlie',
          industry_id: '1',
          occupation: 'aaa',
          company_name: 'aa',
          company_email: "charlie_company_#{SecureRandom.hex(8)}@example.com",
          company_postal_code: '1010001',
          company_address_level1: 'address level 1',
          company_address_level2: 'address level 2',
          company_address_line1: 'address line 1',
          company_address_line2: 'address line 2',
          company_tel: '12345678901',
          department: 'aa',
          position: 'aaa',
          conference_id: conference.id,
          number_of_employee_id: 2,
          annual_sales_id: 3,
          participation: 'オンライン参加'
        )
      end

      before do
        # counter_cacheで自動更新されるため、手動でリセット
        question.update_column(:votes_count, 0)
        create(:session_question_vote, session_question: question, profile:)
        create(:session_question_vote, session_question: question, profile: profile2)
        create(:session_question_vote, session_question: question, profile: profile3)
        # counter_cacheで自動更新されているが、テストのために再度リセット
        question.update_column(:votes_count, 0)
      end

      it 'resets votes_count correctly using reset_counters' do
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
  end
end
