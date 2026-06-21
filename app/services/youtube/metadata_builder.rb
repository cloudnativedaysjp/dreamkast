module Youtube
  # Talk のメタデータから YouTube 動画の snippet(title/description/tags) を生成する。
  class MetadataBuilder
    TITLE_MAX_LENGTH = 100

    def initialize(talk)
      @talk = talk
      @conference = talk.conference
    end

    def snippet
      { title:, description:, tags:, category_id: '28' } # 28 = Science & Technology
    end

    def title
      raw = "#{@talk.title} - #{@conference.name}"
      sanitize(raw).slice(0, TITLE_MAX_LENGTH)
    end

    def description
      lines = []
      lines << @talk.abstract if @talk.abstract.present?
      lines << ''
      speakers = @talk.speaker_names
      lines << "登壇者: #{speakers.join(', ')}" if speakers.present?
      lines << "資料: #{@talk.document_url}" if @talk.document_url.present?
      lines << "#{@conference.name}: https://event.cloudnativedays.jp/#{@conference.abbr}"
      sanitize(lines.join("\n"))
    end

    def tags
      [@conference.abbr, @talk.talk_category&.name].compact
    end

    private

    # YouTube は title/description で < > を許可しない
    def sanitize(text)
      text.to_s.delete('<>')
    end
  end
end
