import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    this.timeout = window.setTimeout(() => {
      this.element.remove()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      window.clearTimeout(this.timeout)
    }
  }
}
