import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    talkId: String,
    talkName: String,
    profileId: String,
    weaverUrl: String
  }
  
  connect() {
    this.startLogging()
  }
  
  disconnect() {
    this.stopLogging()
  }
  
  startLogging() {
    this.stopLogging() // Clear any existing interval
    
    this.loggingInterval = setInterval(() => {
      const timestamp = new Date().toISOString()
      const method = 'POST'
      const query = `mutation { viewTrack(input: {profileID: ${this.profileIdValue}, trackName: "-", talkID: ${this.talkIdValue}}) }`;
      const body = JSON.stringify({ "query": query });
      const headers = { 'Content-Type': 'application/json' };
      try {
        fetch(this.weaverUrlValue,{ method, headers, body})
          .then(r=> {
            console.log(r)
          })
          .catch(e => {
            console.error(e)
          })
      } catch(e) {
        console.error(e)
      }

      // If you need to send this data to the server via Turbo Streams
      // you could dispatch a custom event or make a fetch request here
    }, 10 * 1000) // Log every 10 seconds
  }
  
  stopLogging() {
    if (this.loggingInterval) {
      clearInterval(this.loggingInterval)
      this.loggingInterval = null
    }
  }
}