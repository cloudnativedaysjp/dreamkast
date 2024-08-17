// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import "@hotwired/turbo-rails"

Rails.start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
import '../stylesheets/cndf2023'
import './bootstrap_custom.js'
import './scripts.js'
import './talks.js'
import './speaker_form.js'
import './cropbox.js'
import './timetable.js'



// import 'regenerator-runtime/runtime'
// import "@hotwired/turbo-rails"
// import "controllers"
