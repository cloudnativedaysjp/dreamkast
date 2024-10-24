import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
    connect() {
        this.modal = new Modal(this.element)
        this.modal.show()
    }

    open() {
        this.modal.classList.remove('hidden')
    }

    close(event) {
        if (event.detail.success) {
            this.modal.hide()
        }
    }
}
