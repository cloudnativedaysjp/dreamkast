require 'csv'

# 任意の区切り文字を指定可能 (TSVの場合は "\t" を指定)
CSV.foreach('/Users/r_takaishi/Downloads/cndt2020_proposals.tsv', 'r:UTF-8', col_sep: "\t") do |arr|
  p arr
end