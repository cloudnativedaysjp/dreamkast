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
// import '../stylesheets/cndo2021'
import $ from 'jquery'
import './bootstrap_custom.js'
window.jQuery = $
import './scripts.js'
import './talks.js'
import './conference_form.js'
import './admin.js'
import './contents.js'
import './cropbox.js'
import './timetable.js'
import './attendee_dashboard.js'
import "particles.js";
import './copy.js'
import './speaker_form.js'