# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Sprockets の CSS コンプレッサ (sassc) を無効化する。
# - 配信対象の CSS はすべて webpack 側で MiniCssExtractPlugin + sass-loader (compressed) により minify 済み
# - sassc 2.4 は Tailwind が出力する modern CSS color syntax `rgb(R G B / A)` をパースできず失敗する
#   (sass-rails 経由で sassc-rails が :sass をデフォルト登録するため明示的に無効化する)
Rails.application.config.assets.css_compressor = nil
