require 'rails_helper'

RSpec.describe(CsvFormulaEscaper) do
  def generate(row)
    CSV.parse_line(CSV.generate(**described_class.options) { |csv| csv << row }, row_sep: "\n")
  end

  ['=1+1', '+1', '-1', '@SUM(A1)', "\tA", "\rA", '＝1+1', '＠SUM(A1)'].each do |value|
    it "#{value.inspect} の先頭に ' を付ける" do
      expect(generate([value])).to(eq(["'#{value}"]))
    end
  end

  it '通常の文字列・数値・nilはそのまま出力する' do
    expect(generate(['クラウドネイティブ', 'a=b', 12, nil])).to(eq(['クラウドネイティブ', 'a=b', '12', nil]))
  end
end
