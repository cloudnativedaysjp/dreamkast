require 'rails_helper'

RSpec.describe(TalkSessionAttribute, type: :model) do
  let!(:cndt2020) { create(:cndt2020) }
  let(:talk) { create(:talk1) }
  let(:keynote_attr) { create(:session_attribute, name: 'keynote', is_exclusive: false) }
  let(:sponsor_attr) { create(:session_attribute, name: 'sponsor', is_exclusive: false) }
  let(:intermission_attr) { create(:session_attribute, name: 'intermission', is_exclusive: true) }

  describe 'associations' do
    it 'belongs to talk' do
      association = TalkSessionAttribute.reflect_on_association(:talk)
      expect(association.macro).to(eq(:belongs_to))
    end

    it 'belongs to session_attribute' do
      association = TalkSessionAttribute.reflect_on_association(:session_attribute)
      expect(association.macro).to(eq(:belongs_to))
    end
  end

  describe 'validations' do
    it 'validates uniqueness of talk_id and session_attribute_id combination' do
      create(:talk_session_attribute, talk:, session_attribute: keynote_attr)

      duplicate = build(:talk_session_attribute, talk:, session_attribute: keynote_attr)
      expect(duplicate).not_to(be_valid)
      expect(duplicate.errors[:talk_id]).to(include('already has this session attribute assigned'))
    end

    it 'allows different talks to have same session attribute' do
      other_talk = create(:talk)
      create(:talk_session_attribute, talk:, session_attribute: keynote_attr)

      other_assignment = build(:talk_session_attribute, talk: other_talk, session_attribute: keynote_attr)
      expect(other_assignment).to(be_valid)
    end

    it 'allows same talk to have different session attributes' do
      create(:talk_session_attribute, talk:, session_attribute: keynote_attr)

      other_assignment = build(:talk_session_attribute, talk:, session_attribute: sponsor_attr)
      expect(other_assignment).to(be_valid)
    end
  end

  describe 'exclusive attribute validation' do
    it 'prevents exclusive attribute from coexisting with other attributes' do
      create(:talk_session_attribute, talk:, session_attribute: keynote_attr)

      intermission_assignment = build(:talk_session_attribute, talk:, session_attribute: intermission_attr)
      expect(intermission_assignment).not_to(be_valid)
      expect(intermission_assignment.errors[:session_attribute]).to(include(/exclusive and cannot coexist/))
    end

    it 'prevents other attributes from being added when exclusive attribute exists' do
      # First create the intermission (exclusive) attribute for this talk
      talk.talk_session_attributes.create!(session_attribute: intermission_attr)
      talk.reload

      # Then try to add a keynote attribute - this should fail
      keynote_assignment = build(:talk_session_attribute, talk:, session_attribute: keynote_attr)
      expect(keynote_assignment).not_to(be_valid)
      expect(keynote_assignment.errors[:session_attribute]).to(include(/exclusive and cannot coexist/))
    end

    it 'allows exclusive attribute alone' do
      intermission_assignment = build(:talk_session_attribute, talk:, session_attribute: intermission_attr)
      expect(intermission_assignment).to(be_valid)
    end

    it 'allows multiple non-exclusive attributes together' do
      create(:talk_session_attribute, talk:, session_attribute: keynote_attr)

      sponsor_assignment = build(:talk_session_attribute, talk:, session_attribute: sponsor_attr)
      expect(sponsor_assignment).to(be_valid)
    end
  end

  describe 'callbacks' do
    describe 'sync_legacy_fields' do
      context 'with intermission attribute' do
        it 'sets abstract to intermission when created' do
          expect(talk.abstract).not_to(eq('intermission'))

          create(:talk_session_attribute, talk:, session_attribute: intermission_attr)

          talk.reload
          expect(talk.abstract).to(eq('intermission'))
        end

        it 'removes abstract when destroyed' do
          assignment = create(:talk_session_attribute, talk:, session_attribute: intermission_attr)
          talk.reload
          expect(talk.abstract).to(eq('intermission'))

          assignment.destroy

          talk.reload
          expect(talk.abstract).to(be_nil)
        end

        it 'does not change abstract if already set to intermission' do
          talk.update!(abstract: 'intermission')

          create(:talk_session_attribute, talk:, session_attribute: intermission_attr)

          talk.reload
          expect(talk.abstract).to(eq('intermission'))
        end
      end

      context 'with non-intermission attribute' do
        it 'does not change abstract field' do
          original_abstract = talk.abstract

          create(:talk_session_attribute, talk:, session_attribute: keynote_attr)

          talk.reload
          expect(talk.abstract).to(eq(original_abstract))
        end
      end
    end
  end
end
