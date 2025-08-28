require 'rails_helper'

RSpec.describe(TalkAttributeService, type: :service) do
  let!(:cndt2020) { create(:cndt2020) }
  let(:talk) { create(:talk1) }
  let(:keynote_attr) { create(:talk_attribute, name: 'keynote', is_exclusive: false) }
  let(:sponsor_attr) { create(:talk_attribute, name: 'sponsor', is_exclusive: false) }
  let(:intermission_attr) { create(:talk_attribute, name: 'intermission', is_exclusive: true) }

  describe '.assign_attributes' do
    it 'is a convenience method that creates a new service instance' do
      expect_any_instance_of(TalkAttributeService).to(receive(:assign_attributes).with([keynote_attr.id]))
      TalkAttributeService.assign_attributes(talk, [keynote_attr.id])
    end
  end

  describe '#assign_attributes' do
    let(:service) { TalkAttributeService.new(talk) }

    context 'with valid attribute IDs' do
      it 'assigns single attribute' do
        service.assign_attributes([keynote_attr.id])

        talk.reload
        expect(talk.keynote?).to(be(true))
      end

      it 'assigns multiple non-exclusive attributes' do
        service.assign_attributes([keynote_attr.id, sponsor_attr.id])

        talk.reload
        expect(talk.keynote?).to(be(true))
        expect(talk.sponsor_session?).to(be(true))
      end

      it 'clears existing attributes and assigns new ones' do
        talk.talk_attributes << keynote_attr
        expect(talk.keynote?).to(be(true))

        service.assign_attributes([sponsor_attr.id])

        talk.reload
        expect(talk.keynote?).to(be(false))
        expect(talk.sponsor_session?).to(be(true))
      end

      it 'clears all attributes when empty array provided' do
        talk.talk_attributes << keynote_attr
        expect(talk.keynote?).to(be(true))

        service.assign_attributes([])

        talk.reload
        expect(talk.keynote?).to(be(false))
        expect(talk.talk_attributes).to(be_empty)
      end

      it 'handles nil and blank values' do
        service.assign_attributes([keynote_attr.id, nil, '', sponsor_attr.id])

        talk.reload
        expect(talk.keynote?).to(be(true))
        expect(talk.sponsor_session?).to(be(true))
      end

      it 'assigns exclusive attribute alone' do
        service.assign_attributes([intermission_attr.id])

        talk.reload
        expect(talk.intermission?).to(be(true))
      end
    end

    context 'with invalid attribute IDs' do
      it 'raises ValidationError for non-existent attribute IDs' do
        invalid_id = 99999

        expect {
          service.assign_attributes([invalid_id])
        }.to(raise_error(TalkAttributeService::ValidationError, /Unknown attribute IDs: #{invalid_id}/))
      end

      it 'raises ValidationError for multiple exclusive attributes' do
        exclusive_attr_2 = create(:talk_attribute, name: 'other_exclusive', is_exclusive: true)

        expect {
          service.assign_attributes([intermission_attr.id, exclusive_attr_2.id])
        }.to(raise_error(TalkAttributeService::ValidationError, /Multiple exclusive attributes/))
      end

      it 'raises ValidationError when exclusive attribute coexists with others' do
        expect {
          service.assign_attributes([keynote_attr.id, intermission_attr.id])
        }.to(raise_error(TalkAttributeService::ValidationError, /Exclusive attribute cannot coexist/))
      end

      it 'includes specific attribute names in error messages' do
        exclusive_attr_2 = create(:talk_attribute, name: 'other_exclusive', display_name: 'Other Exclusive', is_exclusive: true)

        expect {
          service.assign_attributes([intermission_attr.id, exclusive_attr_2.id])
        }.to(raise_error(TalkAttributeService::ValidationError, /Other Exclusive/))
      end
    end

    context 'transaction behavior' do
      it 'rolls back all changes when validation fails' do
        # Add an existing attribute
        talk.talk_attributes << keynote_attr
        original_count = talk.talk_attribute_associations.count

        # Try to add invalid combination (should fail)
        invalid_id = 99999
        expect {
          service.assign_attributes([sponsor_attr.id, invalid_id])
        }.to(raise_error(TalkAttributeService::ValidationError))

        # Verify no changes were made
        talk.reload
        expect(talk.talk_attribute_associations.count).to(eq(original_count))
        expect(talk.keynote?).to(be(true))
        expect(talk.sponsor_session?).to(be(false))
      end

      it 'reloads talk after successful assignment' do
        expect(talk).to(receive(:reload))
        service.assign_attributes([keynote_attr.id])
      end
    end

    context 'edge cases' do
      it 'handles string IDs' do
        service.assign_attributes([keynote_attr.id.to_s])

        talk.reload
        expect(talk.keynote?).to(be(true))
      end

      it 'handles mixed valid and invalid IDs' do
        invalid_id = 99999

        expect {
          service.assign_attributes([keynote_attr.id, invalid_id])
        }.to(raise_error(TalkAttributeService::ValidationError, /Unknown attribute IDs: #{invalid_id}/))
      end

      it 'handles duplicate attribute IDs' do
        service.assign_attributes([keynote_attr.id, keynote_attr.id])

        talk.reload
        expect(talk.keynote?).to(be(true))
        expect(talk.talk_attribute_associations.count).to(eq(1)) # Should not create duplicates
      end
    end
  end
end
