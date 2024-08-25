import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["hiddenInput", "linkField"]

    remove(event) {
        this.hiddenInputTarget.value = '1';
        this.linkFieldTarget.style.display = 'none';
        event.preventDefault();
    }
}
