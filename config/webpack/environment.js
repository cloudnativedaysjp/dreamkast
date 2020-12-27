const { environment } = require('@rails/webpacker')
const typescript =  require('./loaders/typescript')


const webpack = require('webpack')
environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        Popper: ['popper.js', 'default']
    })
)

environment.loaders.prepend('typescript', typescript)
module.exports = environment

const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");
const path = require("path");

environment.plugins.append(
    "ForkTsCheckerWebpackPlugin",
    new ForkTsCheckerWebpackPlugin({
        typescript: {
            configFile: path.resolve(__dirname, "../../tsconfig.json"),
        },
        async: false,
    })
);