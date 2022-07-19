// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
import '../stylesheets/cicd2021'
import './bootstrap_custom.js'
import './bootstrap-table.js'
import './utils'
import './bootstrap-table-filter-control.js'
import jquery from 'jquery';
window.$ = window.jquery = jquery;
import './jquery.easing.min.js'
import './jquery.magnific-popup.min.js'
import './scripts.js'
import './talks.js'
import './sponsor_form.js'
import './conference_form.js'
import './admin.js'
import './contents.js'
import './speaker_form.js'

require.context('images', true, /\.(png|jpg|jpeg|svg)$/)