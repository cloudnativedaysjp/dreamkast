module TimetableHelper
  # トラックごとのアクセントカラー。Tailwind のクラス検出のためリテラルで列挙する。
  TIMETABLE_TRACK_ACCENTS = [
    { header: 'tw-border-cndt-navy', card: 'tw-border-l-cndt-navy', text: 'tw-text-cndt-navy' },
    { header: 'tw-border-cndt-magenta', card: 'tw-border-l-cndt-magenta', text: 'tw-text-cndt-magenta' },
    { header: 'tw-border-amber-500', card: 'tw-border-l-amber-500', text: 'tw-text-amber-600' },
    { header: 'tw-border-emerald-600', card: 'tw-border-l-emerald-600', text: 'tw-text-emerald-700' }
  ].freeze

  # 1日分のタイムテーブルのグリッド。
  # 1分を1行、1列目を時刻軸、2列目以降を各トラックとして扱う。
  # どのトラックにもセッションがない時間帯（休憩など）は GAP_ROWS 行に縮める。
  class TimetableGrid
    GAP_ROWS = 4

    attr_reader :tracks
    attr_reader :talks
    attr_reader :total_rows

    def initialize(tracks, talks)
      @tracks = tracks.to_a
      track_ids = @tracks.map(&:id)
      @talks = talks.select { |talk| talk.start_time && talk.end_time && track_ids.include?(talk.track_id) }
                    .sort_by { |talk| [talk.start_time, track_ids.index(talk.track_id)] }
      build_lines
    end

    def track_column(track)
      tracks.index(track) + 2
    end

    def talk_column(talk)
      tracks.index { |track| track.id == talk.track_id } + 2
    end

    def row_start(time)
      @lines.fetch(time.to_i)
    end

    def talk_rows(talk)
      first = row_start(talk.start_time)
      last = [row_start(talk.end_time), first + 1].max
      [first, last]
    end

    # 開始時刻ごとにまとめたセッション（時刻ラベルとモバイル表示の見出しに使う）
    def talks_by_start_time
      talks.group_by(&:start_time)
    end

    def track_accent(track)
      TIMETABLE_TRACK_ACCENTS[tracks.index(track) % TIMETABLE_TRACK_ACCENTS.size]
    end

    def talk_accent(talk)
      track_accent(tracks.find { |track| track.id == talk.track_id })
    end

    private

    # セッションの開始・終了時刻を区切りとして、各時刻がグリッドの何行目の境界にあたるかを求める
    def build_lines
      boundaries = talks.flat_map { |talk| [talk.start_time.to_i, talk.end_time.to_i] }.uniq.sort
      @lines = {}
      line = 1
      boundaries.each_with_index do |time, index|
        @lines[time] = line
        next_time = boundaries[index + 1]
        break unless next_time

        minutes = (next_time - time) / 60
        line += occupied?(time, next_time) ? minutes : [minutes, GAP_ROWS].min
      end
      @total_rows = line - 1
    end

    def occupied?(from, to)
      talks.any? { |talk| talk.start_time.to_i <= from && talk.end_time.to_i >= to }
    end
  end

  def timetable_grid(tracks, talks)
    TimetableGrid.new(tracks, talks)
  end

  def timetable_grid_columns_style(grid)
    "grid-template-columns: 4rem repeat(#{grid.tracks.size}, minmax(0, 1fr));"
  end
end
