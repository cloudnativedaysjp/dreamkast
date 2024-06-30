const path    = require("path")
const webpack = require("webpack")

// CSSを.cssファイルに切り出す
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// CSSのみを含むエントリーから、exportされたJavaScriptファイルを削除する
// この例では、entry.customは対応する空のcustom.jsファイルを作成する
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: [
      "./app/javascript/packs/application.js",
      './app/javascript/stylesheets/application.scss',
    ]
  },
  module: {
    rules: [
      // ローダーを含むCSS/SASS/SCSSルールをここに追加する
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        use: 'file-loader',
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
