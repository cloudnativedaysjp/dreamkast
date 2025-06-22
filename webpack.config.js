const path    = require("path")
const webpack = require("webpack")

// CSSを.cssファイルに切り出す
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// CSSのみを含むエントリーから、exportされたJavaScriptファイルを削除する
// この例では、entry.customは対応する空のcustom.jsファイルを作成する
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');
process.env.RAILS_ENV = process.env.RAILS_ENV || 'development'
process.env.NODE_ENV = process.env.NODE_ENV || process.env.RAILS_ENV

module.exports = {
  mode: ['development', 'production'].includes(process.env.NODE_ENV) ? process.env.NODE_ENV : 'development',
  devtool: "source-map",
  optimization: {
    moduleIds: 'deterministic',
  },
  entry: {
    application: [
      "./app/javascript/packs/application.js",
      './app/javascript/stylesheets/application.scss',
    ],
    cnds2025: [
      "./app/javascript/packs/cnds2025.js",
      './app/javascript/stylesheets/cnds2025.scss',
    ],
    cndw2024: [
      "./app/javascript/packs/cndw2024.js",
      './app/javascript/stylesheets/cndw2024.scss',
    ],
    cnds2024: [
      "./app/javascript/packs/cnds2024.js",
      './app/javascript/stylesheets/cnds2024.scss',
    ],
    cndt2023: [
      "./app/javascript/packs/cndt2023.js",
      './app/javascript/stylesheets/cndt2023.scss',
    ],
    cndf2023: [
      "./app/javascript/packs/cndf2023.js",
      './app/javascript/stylesheets/cndf2023.scss',
    ],
    cicd2021: [
      "./app/javascript/packs/cicd2021.js",
      './app/javascript/stylesheets/cicd2021.scss',
    ],
    talks: [
      "./app/javascript/packs/talks.js",
    ],
    vote_cfp: [
      "./app/javascript/packs/vote_cfp.js",
    ],
    'admin/tracks': [
      "./app/javascript/packs/admin/tracks/index.js",
    ],
    'admin/tracks/media_live': [
      "./app/javascript/packs/admin/tracks/media_live.js",
    ],
    'admin/tracks/tracks_control': [
      "./app/javascript/packs/admin/tracks/tracks_control.js",
    ],
    'chat/index': [
      "./app/javascript/packs/chat/index.js",
    ],
    'tracks/waiting_channel': [
      "./app/javascript/packs/tracks/waiting_channel.js",
    ],
    'tracks/track_channel': [
      "./app/javascript/packs/tracks/track_channel.js",
    ],
    video_player: [
      "./app/javascript/packs/video_player.js",
    ]
  },
  module: {
    rules: [
      // ローダーを含むCSS/SASS/SCSSルールをここに追加する
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          {
            loader: 'sass-loader',
            options: {
              api: 'modern-compiler',
              sassOptions: {
                style: process.env.NODE_ENV === 'production' ? 'compressed' : 'expanded',
              },
            },
          },
        ],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        // generator: {
        //   filename: 'images/[name][ext]',
        // },
        type: 'asset/resource',
      },
    ],
  },
  resolve: {
    // 追加のファイル種別をここに追加する
    extensions: ['.js', '.jsx', '.scss', '.css'],
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    chunkFormat: "module",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    }),
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
  ]
}
