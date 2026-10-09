# http/https の絶対URLのみを許可する。javascript: などのスキームによるXSSを防ぐ。
class HttpUrlValidator < ActiveModel::EachValidator
  HTTP_URL_FORMAT = %r{\Ahttps?://\S*\z}i

  def self.valid_url?(value)
    value.is_a?(String) && HTTP_URL_FORMAT.match?(value)
  end

  def validate_each(record, attribute, value)
    return if value.blank?
    return if self.class.valid_url?(value)

    record.errors.add(attribute, options[:message] || 'は http:// または https:// で始まるURLを入力してください')
  end
end
