require 'rails_helper'

RSpec.describe(ViewerCount, type: :model) do
  describe 'get_latest_number_of_viewer' do
    context 'with opened conference' do
      before do
        create(:cndt2020, :opened)
        create(:talk1)
        create(:talk3)
        create_list(:viewer_count, 3, :talk1)
        create_list(:viewer_count, 3, :talk3)
      end
      after(:each) do
        FactoryBot.rewind_sequences
      end

      context 'if talk is on air' do
        before do
          create(:video, :on_air, :talk1)
          create(:video, :on_air, :talk3)
        end

        it 'include latest count' do
          expect(ViewerCount.latest_number_of_viewers.find_by(talk_id: 1).count).to(eq(3))
          expect(ViewerCount.latest_number_of_viewers.find_by(talk_id: 3).count).to(eq(6))
        end
      end

      context 'if talk is off air' do
        before do
          create(:video, :off_air, :talk1)
          create(:video, :on_air, :talk3)
        end
        it "doesn't include off air talk" do
          expect(ViewerCount.latest_number_of_viewers.find_by(talk_id: 1)).to(be(nil))
          expect(ViewerCount.latest_number_of_viewers.find_by(talk_id: 3).count).to(eq(6))
        end
      end
    end
    context 'with registered conference' do
      before do
        create(:cndt2020, :registered)
        create(:talk1)
        create(:talk3)
        create(:video, :on_air, :talk1)
        create(:video, :on_air, :talk3)
        create_list(:viewer_count, 3, :talk1)
        create_list(:viewer_count, 3, :talk3)
      end
      after(:each) do
        FactoryBot.rewind_sequences
      end

      context 'if talk is off air' do
        it 'doesnt include latest count' do
          expect(ViewerCount.latest_number_of_viewers.find_by(talk_id: 1)).to(be(nil))
          expect(ViewerCount.latest_number_of_viewers.find_by(talk_id: 3)).to(be(nil))
        end
      end
    end
  end
end
