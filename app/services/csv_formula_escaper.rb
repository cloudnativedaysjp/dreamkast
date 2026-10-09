# CSVを表計算ソフトで開いた際に、利用者が入力した値が数式として実行されるのを防ぐ（CSV Injection対策）。
# CSV.generate / CSV.open の write_converters に渡して使う。
module CsvFormulaEscaper
  # 日本語版Excelは全角記号も数式として解釈するため含める
  FORMULA_PREFIXES = ['=', '+', '-', '@', "\t", "\r", '＝', '＋', '－', '＠'].freeze

  CONVERTER = lambda do |field|
    if field.is_a?(String) && field.start_with?(*FORMULA_PREFIXES)
      "'#{field}"
    else
      field
    end
  end

  def self.options
    { write_converters: [CONVERTER] }
  end
end
