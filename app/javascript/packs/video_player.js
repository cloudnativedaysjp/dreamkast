import videojs from 'video.js'
import 'video.js/dist/video-js.css'

// Make videojs available globally for inline scripts
window.videojs = videojs

// Auto-initialize video.js players on page load
document.addEventListener('DOMContentLoaded', function() {
  // Initialize any video elements with video-js class
  const videoElements = document.querySelectorAll('video.video-js')
  videoElements.forEach(function(element) {
    if (!element.hasAttribute('data-vjs-player')) {
      videojs(element)
    }
  })
})

export default videojs