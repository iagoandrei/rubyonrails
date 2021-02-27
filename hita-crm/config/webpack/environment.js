const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const webpack = require('webpack');

environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    JQuery: 'jquery',
    jquery: 'jquery',
    'window.Tether': "tether",
    uppy: 'uppy'
  })
)

environment.loaders.prepend('erb', erb)
module.exports = environment
