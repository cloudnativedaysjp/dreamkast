# == Schema Information
#
# Table name: viewer_counts
#
#  id            :bigint           not null, primary key
#  count         :integer
#  stream_type   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  conference_id :integer
#  talk_id       :integer
#  track_id      :integer
#
# Indexes
#
#  index_viewer_counts_on_conference_id  (conference_id)
#  index_viewer_counts_on_talk_id        (talk_id)
#  index_viewer_counts_on_track_id       (track_id)
#
require 'rails_helper'

RSpec.describe(ViewerCount, type: :model) do
  describe 'get_latest_number_of_viewer' do
    context 'with opened conference' do
      before do
        create(:cndt2020, :opened)
      end

      context 'if talk is on air' do
        before do
          create(:talk1, :on_air)
        end
        it { expect(最新のviewercountが返る) }
        it { expect(過去のviewercountは返らない) }
      end

      context 'if talk is off air' do
        before do
          create(:talk1, :off_air) 
        end
        it { expect(viewercountが返らない) }
      end
    end

    context 'with registered conference' do
      before do
        create(:cndt2020, :registered)
        create(:talk1, :on_air) 
      end
      it { expect(viewercountが返らない) }
    end
  end
end
