import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dismiss() {
    this.element.remove()
  }

  close(event) {
    if (event.detail.success) {
      this.element.remove()
    }
  }
}
