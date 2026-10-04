require 'rails_helper'

describe TimetableHelper, type: :helper do
  let!(:conference) { create(:cndw2026) }
  let(:conference_day) { conference.conference_days.order(:date).first }
  let(:tracks) { conference.tracks.order(:number) }
  let(:grid) { helper.timetable_grid(tracks, conference_day.talks) }

  def create_talk(track_name, start_time, end_time, **attrs)
    create(:talk, conference:, conference_day:, track: tracks.find_by(name: track_name),
                  title: "#{track_name} #{start_time}", start_time:, end_time:, show_on_timetable: true, **attrs)
  end

  describe '#timetable_grid' do
    let!(:talk_a) { create_talk('A', '10:00', '10:40') }
    let!(:talk_d) { create_talk('D', '10:00', '10:40') }
    let!(:talk_b) { create_talk('B', '11:00', '11:20') }

    it '最初のセッションの開始時刻を1行目として、1分を1行で数える' do
      expect(grid.talk_rows(talk_a)).to(eq([1, 41]))
      expect(grid.talk_rows(talk_d)).to(eq([1, 41]))
    end

    it 'どのトラックにもセッションがない時間帯は GAP_ROWS 行に縮める' do
      # 10:40-11:00 の 20 分は空き時間なので 4 行になる
      expect(grid.talk_rows(talk_b)).to(eq([45, 65]))
      expect(grid.total_rows).to(eq(64))
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

  describe '空き時間の扱い' do
    it 'GAP_ROWS より短い空き時間はそのままの長さで表示する' do
      create_talk('A', '10:00', '10:30')
      later = create_talk('A', '10:32', '11:00')

      expect(grid.talk_rows(later)).to(eq([33, 61]))
    end

    it '別トラックのセッションが続いている時間帯は縮めない' do
      create_talk('A', '10:00', '10:30')
      create_talk('B', '10:00', '11:00')
      later = create_talk('A', '10:40', '11:00')

      expect(grid.talk_rows(later)).to(eq([41, 61]))
      expect(grid.total_rows).to(eq(60))
    end
  end

  describe 'トラックや時刻が未設定のセッション' do
    let!(:talk) { create_talk('A', '10:00', '10:40') }
    let!(:no_track_talk) { create(:talk, conference:, conference_day:, title: 'no track', start_time: '12:00', end_time: '12:40') }
    let!(:no_time_talk) { create(:talk, conference:, conference_day:, track: tracks.first, title: 'no time') }

    it '配置しない' do
      expect(grid.talks).to(eq([talk]))
      expect(grid.total_rows).to(eq(40))
    end
  end
end
