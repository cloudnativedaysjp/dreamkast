import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
    connect() {
        console.log("AAAAAAAAAAAAAAAAAAa")
        this.modal = new Modal(this.element)
        this.modal.show()
    }

    // close(event) {
    //     if (event.detail.success) {
    //         this.modal.hide()
    //     }
    // }

    open() {
        this.modal.classList.remove('hidden')
    }

    close() {
        this.modal.classList.add('hidden')
    }
}
