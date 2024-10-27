import { Controller } from "@hotwired/stimulus"
import Toast from 'bootstrap/js/dist/toast'

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    const toast = new Toast(this.element)
    toast.show()
  }
}
