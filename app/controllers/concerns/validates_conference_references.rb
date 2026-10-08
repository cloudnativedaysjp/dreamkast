module ValidatesConferenceReferences
  extend ActiveSupport::Concern

  private

  # 入力された関連 ID が対象イベントに属することを確認する。属さない場合は RecordNotFound。
  def validate_conference_references!(attributes, references)
    references.each do |key, relation|
      ids = Array(attributes[key]).reject(&:blank?)
      relation.find(ids) if ids.any?
    end
    attributes
  end
end
