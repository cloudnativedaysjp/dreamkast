require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#markdown' do
    it 'Markdownを通常どおりHTMLに変換する' do
      html = helper.markdown("# 見出し\n\n[リンク](https://example.com)\n\n| a | b |\n|---|---|\n| 1 | 2 |")
      expect(html).to(include('<h1>見出し</h1>'))
      expect(html).to(include('<a href="https://example.com">リンク</a>'))
      expect(html).to(include('<table>'))
    end

    it 'scriptタグやイベントハンドラを除去する' do
      html = helper.markdown("<script>alert(1)</script>\n\n<img src=x onerror=\"alert(1)\">")
      expect(html).not_to(include('<script'))
      expect(html).not_to(include('onerror'))
    end

    it 'javascriptスキームのリンクを出力しない' do
      html = helper.markdown("[click](javascript:alert(1))\n\n<a href=\"javascript:alert(1)\">x</a>")
      expect(html).not_to(include('href="javascript:'))
    end
  end
end
