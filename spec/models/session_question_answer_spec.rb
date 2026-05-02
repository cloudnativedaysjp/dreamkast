require 'rails_helper'

RSpec.describe SessionQuestionAnswer, type: :model do
  let!(:conference) { create(:cndt2020, :opened) }
  let!(:talk) { create(:talk1, conference:) }
  let!(:profile) { create(:alice, :on_cndt2020, conference:) }
  let!(:speaker) { create(:speaker_alice, conference:) }
  let!(:question) { create(:session_question, talk:, conference:, profile:) }
  let!(:sponsor) { create(:sponsor, conference:) }
  let!(:sponsor_contact) { create(:sponsor_contact, conference:, sponsor:) }

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
          expect(answer.errors[:body]).to include('を入力してください')
        end
      end

      context 'when body is nil' do
        let(:answer) { build(:session_question_answer, session_question: question, speaker:, conference:, body: nil) }

        it 'is invalid' do
          expect(answer).not_to be_valid
          expect(answer.errors[:body]).to include('を入力してください')
        end
      end
    end

    describe 'answerer exclusivity' do
      it 'is valid with only speaker' do
        answer = build(:session_question_answer, session_question: question, speaker:, sponsor_contact: nil, conference:)
        expect(answer).to be_valid
      end

      it 'is valid with only sponsor_contact' do
        answer = build(:session_question_answer, session_question: question, speaker: nil, sponsor_contact:, conference:)
        expect(answer).to be_valid
      end

      it 'is invalid when both speaker and sponsor_contact are set' do
        answer = build(:session_question_answer, session_question: question, speaker:, sponsor_contact:, conference:)
        expect(answer).not_to be_valid
        expect(answer.errors[:base]).to include('speaker と sponsor_contact は同時に指定できません')
      end

      it 'is invalid when neither speaker nor sponsor_contact is set' do
        answer = build(:session_question_answer, session_question: question, speaker: nil, sponsor_contact: nil, conference:)
        expect(answer).not_to be_valid
        expect(answer.errors[:base]).to include('speaker または sponsor_contact のいずれかが必要です')
      end
    end
  end

  describe 'associations' do
    it 'belongs to session_question' do
      expect(subject.class.reflect_on_association(:session_question)).to be_present
    end

    it 'belongs to speaker (optional)' do
      expect(subject.class.reflect_on_association(:speaker)).to be_present
    end

    it 'belongs to sponsor_contact (optional)' do
      expect(subject.class.reflect_on_association(:sponsor_contact)).to be_present
    end

    it 'belongs to conference' do
      expect(subject.class.reflect_on_association(:conference)).to be_present
    end
  end

  describe '#answerer_type' do
    it 'returns "speaker" when speaker is set' do
      answer = build(:session_question_answer, session_question: question, speaker:, sponsor_contact: nil, conference:)
      expect(answer.answerer_type).to eq('speaker')
    end

    it 'returns "sponsor" when sponsor_contact is set' do
      answer = build(:session_question_answer, session_question: question, speaker: nil, sponsor_contact:, conference:)
      expect(answer.answerer_type).to eq('sponsor')
    end
  end

  describe '#answerer_display_name' do
    it 'returns the speaker name when speaker is set' do
      answer = build(:session_question_answer, session_question: question, speaker:, sponsor_contact: nil, conference:)
      expect(answer.answerer_display_name).to eq(speaker.name)
    end

    it 'returns "スポンサー担当者" when sponsor_contact is set and the user is not a speaker on the talk' do
      answer = build(:session_question_answer, session_question: question, speaker: nil, sponsor_contact:, conference:)
      expect(answer.answerer_display_name).to eq('スポンサー担当者')
    end

    it 'returns the speaker name when sponsor_contact_user is also a speaker on the talk' do
      # sponsor_contact の user を talk のスピーカーに紐付ける
      dual_role_speaker = create(:speaker, conference:, user_id: sponsor_contact.user_id,
                                           name: '兼任スピーカー', profile: 'p', company: 'c', job_title: 'j')
      talk.speakers << dual_role_speaker

      answer = create(:session_question_answer, session_question: question, speaker: nil, sponsor_contact:, conference:)
      expect(answer.answerer_display_name).to eq('兼任スピーカー')
    end

    it 'returns "スポンサー担当者" when both ids are nil (after nullify)' do
      # SponsorContact が削除されて dependent: :nullify で sponsor_contact_id が nil になったケースを再現
      answer = create(:session_question_answer, session_question: question, speaker: nil, sponsor_contact:, conference:)
      answer.update_columns(sponsor_contact_id: nil)
      expect(answer.reload.answerer_display_name).to eq('スポンサー担当者')
    end
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
