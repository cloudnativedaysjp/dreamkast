require 'rails_helper'

describe TimetableHelper, type: :helper do
  let!(:conference) { create(:cndw2026) }
  let(:conference_day) { conference.conference_days.order(:date).first }
  let(:tracks) { conference.tracks.order(:number) }

  def create_talk(track_name, start_time, end_time, **attrs)
    create(:talk, conference:, conference_day:, track: tracks.find_by(name: track_name),
                  title: "#{track_name} #{start_time}", start_time:, end_time:, show_on_timetable: true, **attrs)
  end

  describe '#timetable_grid' do
    let!(:talk_a) { create_talk('A', '10:00', '10:40') }
    let!(:talk_d) { create_talk('D', '10:00', '10:40') }
    let!(:talk_b) { create_talk('B', '11:00', '11:20') }
    let(:grid) { helper.timetable_grid(conference_day, tracks, conference_day.talks) }

    it '会期の開始時刻を1行目として、1分を1行で数える' do
      expect(grid.total_rows).to(eq(490))
      expect(grid.talk_rows(talk_a)).to(eq([11, 51]))
      expect(grid.talk_rows(talk_b)).to(eq([71, 91]))
    end

    it '1列目を時刻軸とし、4トラックを2列目から順に並べる' do
      expect(grid.talk_column(talk_a)).to(eq(2))
      expect(grid.talk_column(talk_b)).to(eq(3))
      expect(grid.talk_column(talk_d)).to(eq(5))
      expect(helper.timetable_grid_columns_style(grid)).to(eq('grid-template-columns: 4rem repeat(4, minmax(0, 1fr));'))
    end

    it '開始時刻ごとにトラック順でまとめる' do
      expect(grid.talks_by_start_time.values).to(eq([[talk_a, talk_d], [talk_b]]))
    end

    it 'トラックごとに異なるアクセントカラーを割り当てる' do
      expect(tracks.map { |track| grid.track_accent(track) }.uniq.size).to(eq(4))
      expect(grid.talk_accent(talk_d)).to(eq(grid.track_accent(tracks.last)))
    end
  end

  describe '会期外・未設定のセッション' do
    let!(:early_talk) { create_talk('A', '09:30', '09:50') }
    let!(:late_talk) { create_talk('B', '18:00', '18:30') }
    let!(:no_track_talk) { create(:talk, conference:, conference_day:, title: 'no track', start_time: '12:00', end_time: '12:40') }
    let!(:no_time_talk) { create(:talk, conference:, conference_day:, track: tracks.first, title: 'no time') }
    let(:grid) { helper.timetable_grid(conference_day, tracks, conference_day.talks) }

    it '会期外のセッションが収まるようにグリッドを広げる' do
      expect(grid.talk_rows(early_talk)).to(eq([1, 21]))
      expect(grid.total_rows).to(eq(540))
      expect(grid.talk_rows(late_talk)).to(eq([511, 541]))
    end

    it 'トラックや時刻が未設定のセッションは配置しない' do
      expect(grid.talks).to(contain_exactly(early_talk, late_talk))
    end
  end
end
