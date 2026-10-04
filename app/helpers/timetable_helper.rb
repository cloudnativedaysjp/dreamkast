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
  class TimetableGrid
    attr_reader :tracks
    attr_reader :talks
    attr_reader :start_time
    attr_reader :end_time

    def initialize(conference_day, tracks, talks)
      @tracks = tracks.to_a
      track_ids = @tracks.map(&:id)
      @talks = talks.select { |talk| talk.start_time && talk.end_time && track_ids.include?(talk.track_id) }
                    .sort_by { |talk| [talk.start_time, track_ids.index(talk.track_id)] }

      times = @talks.flat_map { |talk| [talk.start_time, talk.end_time] }
      @start_time = [conference_day.start_time, *times].compact.min
      @end_time = [conference_day.end_time, *times].compact.max
    end

    def total_rows
      return 0 if start_time.nil? || end_time.nil?

      minutes_from_start(end_time)
    end

    def track_column(track)
      tracks.index(track) + 2
    end

    def talk_column(talk)
      tracks.index { |track| track.id == talk.track_id } + 2
    end

    def row_start(time)
      minutes_from_start(time) + 1
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

    def minutes_from_start(time)
      ((time - start_time) / 60).round
    end
  end

  def timetable_grid(conference_day, tracks, talks)
    TimetableGrid.new(conference_day, tracks, talks)
  end

  def timetable_grid_columns_style(grid)
    "grid-template-columns: 4rem repeat(#{grid.tracks.size}, minmax(0, 1fr));"
  end
end
