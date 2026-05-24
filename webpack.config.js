const path = require("path");
const webpack = require("webpack");

// CSSを.cssファイルに切り出す
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
// CSSのみを含むエントリーから、exportされたJavaScriptファイルを削除する
// この例では、entry.customは対応する空のcustom.jsファイルを作成する
const RemoveEmptyScriptsPlugin = require("webpack-remove-empty-scripts");
process.env.RAILS_ENV = process.env.RAILS_ENV || "development";
process.env.NODE_ENV = process.env.NODE_ENV || process.env.RAILS_ENV;

module.exports = {
  mode: ["development", "production"].includes(process.env.NODE_ENV)
    ? process.env.NODE_ENV
    : "development",
  devtool: "source-map",
  optimization: {
    moduleIds: "deterministic",
  },
  entry: {
    application: [
      "./app/javascript/packs/application.js",
      "./app/javascript/stylesheets/application.scss",
    ],
    // Bootstrap → Tailwind 段階移行 (issue #2572): admin 画面専用 Tailwind バンドル
    admin_tailwind: ["./app/javascript/stylesheets/admin_tailwind.scss"],
    cnk: [
      "./app/javascript/packs/cnk.js",
      "./app/javascript/stylesheets/cnk.scss",
    ],
    cnds2025: [
      "./app/javascript/packs/cnds2025.js",
      "./app/javascript/stylesheets/cnds2025.scss",
    ],
    cndw2025: [
      "./app/javascript/packs/cndw2025.js",
      "./app/javascript/stylesheets/cndw2025.scss",
    ],
    cndo2021: [
      "./app/javascript/packs/cndo2021.js",
      "./app/javascript/stylesheets/cndo2021.scss",
    ],
    cicd2021: [
      "./app/javascript/packs/cicd2021.js",
      "./app/javascript/stylesheets/cicd2021.scss",
    ],
    talks: ["./app/javascript/packs/talks.js"],
    vote_cfp: ["./app/javascript/packs/vote_cfp.js"],
    "admin/tracks": ["./app/javascript/packs/admin/tracks/index.js"],
    "admin/tracks/media_live": [
      "./app/javascript/packs/admin/tracks/media_live.js",
    ],
    "chat/index": ["./app/javascript/packs/chat/index.js"],
    "tracks/waiting_channel": [
      "./app/javascript/packs/tracks/waiting_channel.js",
    ],
    "tracks/track_channel": ["./app/javascript/packs/tracks/track_channel.js"],
    video_player: ["./app/javascript/packs/video_player.js"],
  },
  module: {
    rules: [
      // ローダーを含むCSS/SASS/SCSSルールをここに追加する
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader",
          {
            // Tailwind CSS の @tailwind / @apply 等を処理するため postcss-loader を挟む。
            // @tailwind を含まない既存 SCSS には実質ノーオペで autoprefixer のみが効く。
            loader: "postcss-loader",
            options: {
              // ルートの postcss.config.js は CLI (build:css) 専用なので
              // webpack 側では auto-discovery を無効化して inline 設定だけ使う。
              postcssOptions: {
                config: false,
                plugins: [
                  require("tailwindcss"),
                  require("autoprefixer"),
                ],
              },
            },
          },
          {
            loader: "sass-loader",
            options: {
              api: "modern-compiler",
              sassOptions: {
                silenceDeprecations: [
                  "mixed-decls",
                  "color-functions",
                  "global-builtin",
                  "import",
                ],
                style:
                  process.env.NODE_ENV === "production"
                    ? "compressed"
                    : "expanded",
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
        type: "asset/resource",
      },
    ],
  },
  resolve: {
    // 追加のファイル種別をここに追加する
    extensions: [".js", ".jsx", ".scss", ".css"],
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    chunkFormat: "module",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
  ],
};
